// Author: Dylan Turner
// Description: Entry point for game

const std = @import("std");
const sdl = @import("sdl.zig");
const settings = @import("settings.zig");
const app = @import("app.zig");

pub fn main() !void {
    var game = try app.App.init();
    defer game.deinit();

    var quit = false;
    var timer = try std.time.Timer.start();
    var elapsed_time_s: f64 = 0;
    while(!quit) {
        // Handle events always
        var event: sdl.Event = undefined;
        while(sdl.pollEvent(&event) != 0) {
            switch(event.@"type") {
                sdl.QUIT => {
                    quit = true;
                }, else => {
                    game.handle_event(event);
                }
            }
        }

        // Calculate delta
        const dt_ns = timer.lap();
        const dt_s = @intToFloat(f64, dt_ns) / @intToFloat(f64, std.time.ns_per_s);
        game.update(dt_s);

        // Don't render until 1/fps seconds have passed
        elapsed_time_s += dt_s;
        const min_dt_s = 1.0 / @intToFloat(f64, settings.FPS);
        if(elapsed_time_s > min_dt_s) {
            elapsed_time_s = 0;
        
            // Draw to screen
            game.draw();
        }
    }
}

