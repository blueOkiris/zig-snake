const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zig-snake", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    exe.addLibPath("./");

    // Add SDL2 dependencies
    exe.addIncludeDir("sdl2/include/");
    exe.linkSystemLibrary("SDL2");

    // Add SDL2_image deps
    exe.addIncludeDir("sdl2-img/include/");
    exe.linkSystemLibrary("SDL2_image");

    // Add SDL2_ttf deps
    exe.addIncludeDir("sdl2-ttf/include/");
    exe.linkSystemLibrary("SDL2_ttf");

    // Extras to make everything work
    exe.linkSystemLibrary("m");
    exe.linkSystemLibrary("pthread");
    exe.linkSystemLibrary("rt");
    exe.linkLibC();
    
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
