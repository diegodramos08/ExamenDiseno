#ifndef __VGA_TEXTWINDOW_H__
#define __VGA_TEXTWINDOW_H__

#include <cstdint>
#include <memory>
#include <vector>
#include <SDL.h>

#define CHAR_WIDTH      8
#define CHAR_HEIGHT     16
#define BYTES_PER_ROW   ((CHAR_WIDTH + 7) / 8)
#define CHAR_SIZE_BYTES ((BYTES_PER_ROW) * (CHAR_HEIGHT))
#define ROW_MSB         7
#define VGA_COLS        80
#define VGA_ROWS        30
#define VGA_NUM_COLORS  16
#define VGA_NUM_SYMBOLS 256

struct ReleaseWindow
{
    void operator()(SDL_Window *w) {
        if (w != nullptr) {
            SDL_DestroyWindow(w);
        }
    }
};

struct ReleaseRenderer
{
    void operator()(SDL_Renderer *r) {
        if (r != nullptr) {
            SDL_DestroyRenderer(r);
        }
    }
};

using WindowUPtr = std::unique_ptr<SDL_Window, ReleaseWindow>;
using RedererUPtr = std::unique_ptr<SDL_Renderer, ReleaseRenderer>;

namespace Vga
{    
    struct Point: public SDL_Point
    {
        Point() = default;
        
        Point(int x, int y)
        : SDL_Point({x, y})
        {
        }
    };

    class Symbol
    {
    public:
        Symbol() = default;

        Symbol(Symbol&& rhs)
        : points(std::move(rhs.points))
        {
        }

        Symbol(const Symbol& rhs) = default;

        void addPixel(int x, int y) {
            points.emplace_back(x, y);
        }

        Point& operator[](size_t index) {
            return points[index];
        }

        std::vector<Point> getPoints(int x, int y) const
        {   
            std::vector<Point> pts;

            pts.reserve(points.size());
            for (const auto& pt : points)
            {
                pts.emplace_back(x + pt.x, y + pt.y);
            }
            return pts;
        }

        size_t size() const { return points.size(); }

        const Point& operator[](size_t index) const {
            return points[index];
        }

    private:
        std::vector<Point> points;
    };

    class TextWindow {
    public:
        TextWindow(int width, int height)
        : width(width), height(height),
          window(nullptr), renderer(nullptr),
          is_repainting(false)
        {
        }

        ~TextWindow() {}

        bool initDisplay(uint16_t *vgaram, uint8_t *vgarom, uint8_t *vgapal);
        void paint();
        
        void update(size_t offset, uint16_t data)
        { 
            is_repainting = true;
            redrawSymbol(offset, data);
            SDL_RenderPresent(renderer.get());
            SDL_UpdateWindowSurface(window.get());
            is_repainting = false;
        }

        bool isRepainting() { return is_repainting; }
        void redrawSymbol(size_t offset, uint16_t symb);
        void initVGAContent();
        void saveScreenshot(const char *filename);
        bool windowClosed();

        uint32_t getId() { return SDL_GetWindowID(window.get()); }
        int getWidth() { return width; }
        int getHeight() { return height; }

    private:
        void loadVGAFont(const uint8_t *vga_font);
        Symbol loadVGAFontSymbol(const uint8_t *symb_data);
        void drawVGASymbol(int row, int col, uint16_t symb);
        void getColorFromPalette(uint8_t color_index, SDL_Color &sdlcolor);
        void drawChar(int x, int y, SDL_Color &fgcolor, SDL_Color &bgcolor, uint8_t charIndex);

    private:
        WindowUPtr window;
        RedererUPtr renderer;
        uint16_t *vgaram;
        uint8_t  *vgapalette;
        std::vector<Symbol> vga_symbs;
        int width, height; // Screen resolution
        bool is_repainting;
        size_t dirty_offset;
    };
} // namespace Vga

#endif
