const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const c_options = .{ "-Wall", "-Wextra", "-Werror", "-pedantic", "-Isrc" };

    const exe = b.addExecutable(.{
        .name = "social-network",
        .target = target,
        .optimize = optimize,
    });
    exe.addCSourceFiles(&.{ "src/social_network.cpp", "src/user.cpp", "src/network.cpp" }, &c_options);
    exe.linkLibCpp();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const runs = b.step("run", "Run the app");
    runs.dependOn(&run_cmd.step);

    const tests = b.step("test", "Run unit tests");

    const TestDerivation = struct {
        src: []const u8,
        name: []const u8,
    };

    const test_derivation = [_]TestDerivation{
        // TestDev{ .src = "tests/test_user_1.cpp", .name = "test-user-1" },
        // TestDev{ .src = "tests/test_user_2.cpp", .name = "test-user-2" },
        .{ .src = "tests/test_user_3.cpp", .name = "test-user-3" },
        .{ .src = "tests/test_user_4.cpp", .name = "test-user-4" },

        // just build "./src/tests/test_user_add_friend.cpp ./src/user.cpp" "test-user-add"
        .{ .src = "tests/test_user_add_duplicate_friend.cpp", .name = "test-user-add-duplicate" },
        // just build "./src/tests/test_user_delete_friend.cpp ./src/user.cpp" "test-user-delete"
        // just build "./src/tests/test_user_get_friend_reference.cpp ./src/user.cpp" "test-user-get"

        // just build "./src/tests/test_network_.cpp ./src/user.cpp ./src/network.cpp" "test-network"
        // just build "./src/tests/test_network_add_user.cpp ./src/user.cpp ./src/network.cpp" "test-network-add-user"
        // just build "./src/tests/test_network_add_connection.cpp ./src/user.cpp ./src/network.cpp" "test-network-add"
        // just build "./src/tests/test_network_add_duplicate_connection.cpp ./src/user.cpp ./src/network.cpp" "test-network-adddup"
        .{ .src = "tests/test_network_add_invalid_connection.cpp", .name = "test-network-add-invalid" },
        .{ .src = "tests/test_network_delete_connection.cpp", .name = "test-network-delete-con" },
        .{ .src = "tests/test_network_delete_invalid_connection.cpp", .name = "test-network-delete-bad" },

        // just build "./src/tests/test_network_get_id.cpp ./src/user.cpp ./src/network.cpp" "test-network-del-badcon"
        // just build "./src/tests/test_network_get_user.cpp ./src/user.cpp ./src/network.cpp" "test-network-del-badcon"
        .{ .src = "tests/test_network_get_user_nullptr.cpp", .name = "test-network-get-user-null" },
        .{ .src = "tests/test_network_read_user.cpp", .name = "test-network-read-user1" },
        .{ .src = "tests/test_network_read_user2.cpp", .name = "test-network-read-user2" },
    };

    for (test_derivation) |t| {
        const tester = b.addExecutable(.{
            .name = t.name,
            .target = target,
            .optimize = optimize,
        });
        tester.addCSourceFile(.{ .file = .{ .path = t.src }, .flags = &c_options });
        tester.addCSourceFiles(&.{ "src/user.cpp", "src/network.cpp" }, &c_options);
        tester.linkLibCpp();

        const unit_test = b.addRunArtifact(tester);
        tests.dependOn(&unit_test.step);
    }
}
