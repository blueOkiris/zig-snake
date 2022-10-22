// Author: Dylan Turner
// Description: Structs and such for drawing, sound, etc

const sdl = @import("sdl.zig");

// When creating, use "defer sdl.SDL_DestroyTexture(<var-name>.tex)"
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
        const loaded_surface = sdl.img_load(file_name) orelse {
            sdl.log(
                "Unable to load image '%s'! SDL_image: %s",
                file_name, sdl.img_get_error()
            );
            return error.img_load_failed;
        };
        defer sdl.free_surface(loaded_surface);

        const new_tex = sdl.create_texture_from_surface(renderer, loaded_surface) orelse {
            sdl.log(
                "Unable to create texture from image '%s'! SDL_image: %s",
                file_name, sdl.img_get_error()
            );
            return error.img_load_failed;
        };

        var tex_width: i32 = 0;
        var tex_height: i32 = 0;
        _ = sdl.query_texture(new_tex, null, null, &tex_width, &tex_height);

        return Sprite {
            .tex = new_tex,
            .x = 0.0,
            .y = 0.0,
            .width = tex_width,
            .height = tex_height,
            .scale_x = 1.0,
            .scale_y = 1.0
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
        _ = sdl.render_copy(renderer, spr.tex, &src, &dest);
    }
};
