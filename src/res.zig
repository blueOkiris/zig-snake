// Author: Dylan Turner
// Description: Structs and such for drawing, sound, etc

const sdl = @import("sdl.zig");
const err = @import("error.zig");

// Unnecessary refactor: Split Texture and Sprite into two structs
// Alla Font and Text
// There are reused images throughout sprites. There are work arounds, but are non-ideal
// So that's a good refactor
pub const Sprite = struct {
    tex: *sdl.Texture,
    x: f32,
    y: f32,
    width: i32,
    height: i32,
    scale_x: f32,
    scale_y: f32,

    pub fn init(file_name: *const u8, renderer: *sdl.Renderer) !Sprite {
        // Load
        const loaded_surface = sdl.imgLoad(file_name) orelse {
            sdl.log(
                "Unable to load image '%s'! SDL_image: %s",
                file_name, sdl.imgGetError()
            );
            return err.SnakeError.ImageLoadFailed;
        };
        defer sdl.freeSurface(loaded_surface);

        const new_tex = sdl.createTextureFromSurface(renderer, loaded_surface) orelse {
            sdl.log(
                "Unable to create texture from image '%s'! SDL_image: %s",
                file_name, sdl.imgGetError()
            );
            return err.SnakeError.ImageLoadFailed;
        };

        var tex_width: i32 = 0;
        var tex_height: i32 = 0;
        _ = sdl.queryTexture(new_tex, null, null, &tex_width, &tex_height);

        return Sprite {
            .tex = new_tex,
            .x = 0.0,
            .y = 0.0,
            .width = tex_width,
            .height = tex_height,
            .scale_x = 1.0,
            .scale_y = 1.0,
        };
    }

    pub fn draw(spr: *const Sprite, renderer: *sdl.Renderer) void {
        var src = sdl.Rect {
            .x = 0,
            .y = 0,
            .w = spr.width,
            .h = spr.height
        };
        var dest = sdl.Rect {
            .x = @floatToInt(i32, spr.x),
            .y = @floatToInt(i32, spr.y),
            .w = @floatToInt(i32, @intToFloat(f32, spr.width) * spr.scale_x),
            .h = @floatToInt(i32, @intToFloat(f32, spr.height) * spr.scale_y)
        };
        _ = sdl.renderCopy(renderer, spr.tex, &src, &dest);
    }

    pub fn draw_rotated(spr: *const Sprite, renderer: *sdl.Renderer, rot: f64) void {
        var src = sdl.Rect {
            .x = 0,
            .y = 0,
            .w = spr.width,
            .h = spr.height
        };
        var dest = sdl.Rect {
            .x = @floatToInt(i32, spr.x),
            .y = @floatToInt(i32, spr.y),
            .w = @floatToInt(i32, @intToFloat(f32, spr.width) * spr.scale_x),
            .h = @floatToInt(i32, @intToFloat(f32, spr.height) * spr.scale_y)
        };
        _ = sdl.renderCopyEx(renderer, spr.tex, &src, &dest, rot, null, sdl.FLIP_NONE);
    }

    pub fn deinit(spr: *Sprite) void {
        sdl.destroyTexture(spr.tex);
    }
};

pub const Font = struct {
    font: *sdl.Font,

    pub fn init(file_name: *const u8, size: i32) !Font {
        const font = sdl.openFont(file_name, size) orelse {
            sdl.log(
                "Unable to load font '%s'! SDL_ttf: %s",
                file_name, sdl.ttfGetError()
            );
            return err.SnakeError.FontLoadFailed;
        };

        return Font {
            .font = font
        };
    }

    pub fn deinit(font: *Font) void {
        sdl.closeFont(font.font);
    }
};

pub const Text = struct {
    tex: *sdl.Texture,
    x: f32,
    y: f32,
    width: i32,
    height: i32,

    pub fn init(
            font: *Font, text: *const u8, r: u8, g: u8, b: u8, a: u8,
            renderer: *sdl.Renderer) !Text {
        const color = sdl.Color {
            .r = r,
            .g = g,
            .b = b,
            .a = a
        };
        const text_surface = sdl.renderTextSolid(font.font, text, color) orelse {
            sdl.log(
                "Unable to create text '%s'! SDL_ttf: %s",
                text, sdl.ttfGetError()
            );
            return err.SnakeError.FontLoadFailed;
        };
        defer sdl.freeSurface(text_surface);

        const tex = sdl.createTextureFromSurface(renderer, text_surface) orelse {
            sdl.log(
                "Unable to create texture from surface for text '%s'! SDL_ttf: %s",
                text, sdl.ttfGetError()
            );
            return err.SnakeError.FontLoadFailed;
        };

        return Text {
            .tex = tex,
            .x = 0.0,
            .y = 0.0,
            .width = text_surface.*.w,
            .height = text_surface.*.h
        };
    }

    pub fn draw(text: *const Text, renderer: *sdl.Renderer) void {
        var dest = sdl.Rect {
            .x = @floatToInt(i32, text.x),
            .y = @floatToInt(i32, text.y),
            .w = text.width,
            .h = text.height
        };
        _ = sdl.renderCopy(renderer, text.tex, null, &dest);
    }

    pub fn deinit(text: *Text) void {
        sdl.destroyTexture(text.tex);
    }
};

