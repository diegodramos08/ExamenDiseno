#include <cstdlib>
#include <iostream>
#include <string>
#include <memory>
#include <thread>
#include <chrono>
#include <verilated.h>
#include <SDL.h>
#include "VGATextWindow.h"
#include "VVGATest_DualPortVGARam.h"
#include "VVGATest_FontRom.h"
#include "VVGATest_RomColorPalette.h"
#include "VVGATest_VGATextCard.h"
#include "VVGATest_KeypadSampleFSM.h"
#include "VVGATest_VGATest.h"
#include "VVGATest.h"
#include "MifLoader.h"
#include "keypad.h"

using namespace std::chrono_literals;

Vga::TextWindow *vga_wnd;
size_t millis_count;
uint8_t keypad;
Uint32 updateVGAEventType;

void postRepaintEvent(Uint32 wid);

void usage(const char *progname)
{
    std::cerr << "Usage : " << progname << " -s --font-rom-mif <mif file>\n"
              << "Arguments are optional. If no MIF file argument provided the init file\n"
              << "will be looked in the folder where the application is installed\n";
}

// Update the milliseconds count every millisecond
Uint32 updateMillis(Uint32 interval, void *param)
{
    millis_count++;
    return interval;
}

int millis()
{
    return millis_count;
}

void runVerilogModule(VVGATest *vga_test);

int main(int argc, char *argv[])
{
    char *progname = argv[0];
    argc--;
    argv++;
    srand(time(NULL));

    std::string bmp_file = "vga_display.bmp";
    bool print_scr = false;
    bool init_vga_fb = false;
    for (int i = 0; i < argc; i++)
    {
        if (strcmp(argv[i], "-s") == 0)
            print_scr = true;
        else if (strcmp(argv[i], "-i") == 0)
            init_vga_fb = true;
        else if (strcmp(argv[i], "-sf") == 0)
        {
            if (i < argc - 1)
            {
                bmp_file = argv[i + 1];
                i++;
            }
            else
            {
                usage(progname);
                return 1;
            }
        }
        else
        {
            usage(progname);
            return 1;
        }
    }

    if (SDL_Init(SDL_INIT_VIDEO|SDL_INIT_TIMER) != 0)
    {
        std::cerr << "Unable to initialize SDL: " << SDL_GetError() << "\n";
        return 1;
    }

    updateVGAEventType = SDL_RegisterEvents(1);
    if (updateVGAEventType == ((Uint32)-1))
    {
        std::cerr << "Unable to create event type. " << SDL_GetError() << "\n";
        return 1;
    }

    std::unique_ptr<VVGATest> vga_test = std::make_unique<VVGATest>();
    uint16_t *vga_fb = vga_test->VGATest->vga_text->framebuff->memory;
    uint8_t *vga_font = vga_test->VGATest->vga_text->fontrom->memory;
    uint8_t *vga_pal = vga_test->VGATest->vga_text->palrom->memory;
    
    millis_count = 0;
    vga_test->clk = 0;
    vga_test->rst = 0;
    vga_test->eval(); // Execute initial blocks

    std::unique_ptr<Vga::TextWindow> vgatw = std::make_unique<Vga::TextWindow>(640, 480);
    if (!vgatw->initDisplay(vga_fb, vga_font, vga_pal))
    {
        std::cerr << "Couldn't initialize VGA display\n";
        return 1;
    }

    vga_wnd = vgatw.get();
    if (init_vga_fb)
        vgatw->initVGAContent();

    SDL_TimerID ms_tmr = SDL_AddTimer(1, updateMillis, nullptr);
    std::thread vthread(runVerilogModule, vga_test.get());

    bool running = true;
    keypad = 0;

    while (running)
    {
        SDL_Event e;
        SDL_WaitEvent(&e);
        switch (e.type)
        {
            case SDL_QUIT:
                running = false;
                break;
            case SDL_WINDOWEVENT:
                if (e.window.event == SDL_WINDOWEVENT_EXPOSED)
                    vgatw->paint();
                break;
            case SDL_KEYDOWN:
                updateKeypadState(keypad, e.key.keysym.sym, KeyState::Pressed);
                break;
            case SDL_KEYUP:
                updateKeypadState(keypad, e.key.keysym.sym, KeyState::Released);
                break;
            default:
                if (e.type == updateVGAEventType)
                    vgatw->update(reinterpret_cast<size_t>(e.user.data1),
                                  reinterpret_cast<size_t>(e.user.data2));
                break;
        }
    }
    Verilated::gotFinish(true);

    if (print_scr)
        vgatw->saveScreenshot(bmp_file.c_str());

    SDL_Quit();

    vthread.join(); // Wait for the verilog to finish
    vga_test->final(); // Done simulating

    std::cout << "Good byte!\n";

    return 0;
}

void updateVGA(int addr, int write_data)
{
    while (vga_wnd->isRepainting())
    {
        std::this_thread::yield();
    }

    SDL_Event event;
    SDL_memset(&event, 0, sizeof(event));
    event.type = updateVGAEventType;
    event.user.data1 = reinterpret_cast<void *>(addr);
    event.user.data2 = reinterpret_cast<void *>(write_data);

    SDL_PushEvent(&event);
}

void runVerilogModule(VVGATest *vga_test)
{
    // Reset pulse
    vga_test->keypad = 0;
    vga_test->rst = 1;
    vga_test->clk = 1;
    vga_test->eval();
    vga_test->rst = 0;
    vga_test->eval();

    while (!Verilated::gotFinish())
    {
        vga_test->clk = !vga_test->clk;
        vga_test->keypad = keypad;
        vga_test->random = rand() % 2400;
        vga_test->eval();
        std::this_thread::sleep_for(10ms);
    }
}

void postRepaintEvent(Uint32 wid)
{
    SDL_Event event;

    event.type = SDL_WINDOWEVENT;
    event.window.event = SDL_WINDOWEVENT_EXPOSED;
    event.window.windowID = wid;

    SDL_PushEvent(&event);
}
