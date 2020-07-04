#include <stdio.h>
#include <iostream>
#include "VGATextWindow.h"

namespace Vga
{    
    bool TextWindow::initDisplay(uint16_t *vgaram, uint8_t *vgarom, uint8_t *vgapal)
    {
        window.reset(
            SDL_CreateWindow("VGA Display",
                             SDL_WINDOWPOS_CENTERED,
                             SDL_WINDOWPOS_CENTERED,
                             width,
                             height,
                             SDL_WINDOW_OPENGL|SDL_WINDOW_ALWAYS_ON_TOP
                            )
        );

        if (window == nullptr) {
            std::cerr << "Could not create window: '" << SDL_GetError() << "\n";
            return false;
        }

        // renderer.reset( SDL_CreateRenderer(window.get(), -1, SDL_RENDERER_ACCELERATED) );
        SDL_Surface *surface = SDL_GetWindowSurface(window.get());
        renderer.reset( SDL_CreateSoftwareRenderer(surface) );

        if (renderer == nullptr) {
            std::cerr << "Could not create renderer: '" << SDL_GetError() << "\n";
            return false;
        }

        this->vgaram = vgaram;
        this->vgapalette = vgapal;

        loadVGAFont(vgarom);

        SDL_RenderClear(renderer.get());

        return true;
    }

    void TextWindow::initVGAContent()
    {
        uint16_t *p = vgaram;
        uint16_t attr = 0x9f00;
        uint8_t ch = 0;

        for (int r = 0; r < VGA_ROWS; r++)
        {
            for (int col = 0; col < VGA_COLS; col++)
            {
                *p++ = attr | static_cast<uint16_t>(ch);
                ch++;
            }
        }
    }

    void TextWindow::loadVGAFont(const uint8_t *vga_font)
    {
        for (int i = 0; i < VGA_NUM_SYMBOLS; i++)
        {
            const uint8_t *symb_data = &vga_font[i * CHAR_SIZE_BYTES];
            Symbol symb = loadVGAFontSymbol(symb_data);

            vga_symbs.push_back(std::move(symb));
        }
    }

    Symbol TextWindow::loadVGAFontSymbol(const uint8_t *symb_data)
    {
        int pixel_y = 0;

        Symbol symb;
        for (int i = 0; i < CHAR_HEIGHT; i++)
        {
            uint8_t line_data = *symb_data;
            uint8_t mask = 1 << ROW_MSB;

            int pixel_x = 0;
            for (int j = 0; j < CHAR_WIDTH; j++)
            {
                if ((line_data & mask) != 0)
                {
                    symb.addPixel(pixel_x, pixel_y);
                }
                pixel_x++;
                mask >>= 1;
            }
            symb_data += BYTES_PER_ROW;
            pixel_y++;
        }
        return symb;
    }

    void TextWindow::getColorFromPalette(uint8_t color_index, SDL_Color &sdlcolor) {
        sdlcolor.a = 255;

        if (color_index >= 0 && color_index < 16) {
            uint8_t color = vgapalette[color_index];

            sdlcolor.r = color & 0xe0;
            sdlcolor.g = (color & 0x1c) * 8;
            sdlcolor.b = (color & 0x03) * 64;
        } else {
            std::cerr << "Invalid color index '" << color_index << "'\n";
            sdlcolor.r = 0;
            sdlcolor.g = 0;
            sdlcolor.b = 0;
        }
    }

    void TextWindow::drawChar(int x, int y, SDL_Color &fgc, SDL_Color &bgc, uint8_t ch)
    {
        const Symbol &symb = vga_symbs[ch];
        SDL_Rect rect{x, y, CHAR_WIDTH, CHAR_HEIGHT};

        SDL_SetRenderDrawColor(renderer.get(), bgc.r, bgc.g, bgc.b, bgc.a);
        SDL_RenderFillRect(renderer.get(), &rect);
        std::vector<Point> points = symb.getPoints(x, y);

        SDL_SetRenderDrawColor(renderer.get(), fgc.r, fgc.g, fgc.b, fgc.a);
        SDL_RenderDrawPoints(renderer.get(), points.data(), points.size());
    }

    void TextWindow::drawVGASymbol(int row, int col, uint16_t symb)
    {
        uint8_t ch_idx = (uint8_t)(symb & 0xff);
        uint8_t fg_idx = (symb & 0x0f00) >> 8;
        uint8_t bg_idx = (symb & 0xf000) >> 12;

        SDL_Color fgcolor, bgcolor;
        getColorFromPalette(fg_idx, fgcolor);
        getColorFromPalette(bg_idx, bgcolor);
        drawChar(col * CHAR_WIDTH, row * CHAR_HEIGHT, fgcolor, bgcolor, ch_idx);    
    }

    void TextWindow::redrawSymbol(size_t offset, uint16_t symb)
    {
        unsigned row = offset / VGA_COLS;
        unsigned col = offset - (row * VGA_COLS);
        
        drawVGASymbol(row, col, symb);
    }

    void TextWindow::paint()
    {
        is_repainting = true;
        SDL_RenderClear(renderer.get());

        uint16_t *pvga = vgaram;
        for (int row = 0; row < VGA_ROWS; row++)
        {
            for (int col = 0; col < VGA_COLS; col++)
            {
                drawVGASymbol(row, col, *pvga++);
            }
        }
        SDL_RenderPresent(renderer.get());

        is_repainting = false;
    }

    bool TextWindow::windowClosed() {
        SDL_Event e;
        if (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) {
                return true;
            }
        }

        return false;
    }

    void TextWindow::saveScreenshot(const char *filename)
    {
        SDL_Surface *surface = SDL_GetWindowSurface(window.get());
        if(surface != nullptr)
        {
            SDL_SaveBMP(surface, filename);
            SDL_FreeSurface(surface);
        }
    }

} // namespace Vga