#include <dlfcn.h>

#include <SDL2/SDL.h>


static void (*__sdl__SDL_RenderPresent) (SDL_Renderer*) = nullptr;


void SDL_RenderPresent (SDL_Renderer* renderer)
{
    if (__sdl__SDL_RenderPresent == nullptr)
    {
        __sdl__SDL_RenderPresent = (void (*) (SDL_Renderer*)) dlsym (RTLD_NEXT, "SDL_RenderPresent");
    }

    SDL_SetRenderDrawBlendMode (renderer, SDL_BLENDMODE_BLEND);
    
    SDL_Rect rect { 50, 50, 200, 100 };
    SDL_Color color { 255, 0, 0, 128 };

    SDL_Surface* overlay = SDL_CreateRGBSurface (
        0, 
        rect.w, rect.h, 
        32, 
        0, 0, 0, 0
    );


    Uint32 rectColor = SDL_MapRGBA (
        overlay->format, 
        color.r, color.g, color.b, color.a
    );
    
    SDL_FillRect (overlay, &rect, rectColor);

    __sdl__SDL_RenderPresent (renderer);

    SDL_FreeSurface (overlay);
}
