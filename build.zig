const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("bnc", "src/main.zig");
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.install();

    const exe = b.addExecutable("example", "src/example.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.addPackagePath("bnc", "src/main.zig");
    exe.install();

    //var main_tests = b.addTest("src/main.zig");
    //main_tests.setBuildMode(mode);

    //const test_step = b.step("test", "Run library tests");
    //test_step.dependOn(&main_tests.step);

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the example");
    run_step.dependOn(&run_cmd.step);
}
