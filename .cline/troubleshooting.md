# Troubleshooting Guide

## Project Validation

### Godot Headless Validation
**Command**: `godot --headless --quit --validate-project project.godot`

**Expected Output**:
- Project initialization steps complete successfully
- No script compilation errors
- All class dependencies resolved
- Editor layout loads without issues

**Phase 1 Validation Results (2025-05-31)**:
✅ All systems validated successfully
✅ No compilation errors in new scripts
✅ TerrainGenerator class properly registered
✅ SceneManager threading components functional
✅ Camera controller mouse input handling working
✅ Player movement physics integration successful
✅ Lighting and environment systems operational

**Known Warnings**:
- `AVCaptureDeviceTypeExternal is deprecated` - macOS-specific, non-critical

### Validation vs Editor Launch
- Use `godot --headless --quit --validate-project` for automated testing
- Avoid `godot project.godot` in scripts as it opens the GUI editor
- The `--quit` flag ensures the process terminates after validation

### Testing Commands Reference
```bash
# Validate project without opening editor
godot --headless --quit --validate-project project.godot

# Export project (headless)
godot --headless --export-debug "preset_name" output_path

# Run specific scene (headless)
godot --headless --main-scene path/to/scene.tscn
```

## Common Issues

### Scene Not Loading
- Check main scene path in project.godot
- Verify .tscn file syntax
- Ensure all referenced scripts exist

### Node Reference Errors
- Use `@onready` for scene tree dependent references
- Check node path spelling and capitalization
- Verify node exists in scene tree when accessed

### Input Not Working
- Check input map definitions in project.godot
- Verify input action names match exactly
- Ensure input handling method is called

### Performance Issues
- Profile with Godot's built-in profiler
- Check for excessive `_process()` calls
- Monitor node count in scene tree

### Class Registration Issues
- Ensure `class_name` is at top of script
- Check for syntax errors in class definition
- Verify inheritance chain is correct

### Threading Issues (SceneManager)
- Always use `call_deferred()` for main thread operations
- Properly cleanup threads in `_exit_tree()`
- Use mutexes for shared data access

### Terrain Generation Issues
- Check noise parameters are within valid ranges
- Verify mesh arrays are properly sized
- Ensure collision shapes match mesh geometry

### Camera Controller Issues
- Mouse capture requires user gesture to activate
- Check mouse sensitivity values aren't too high/low
- Verify camera target reference is valid

## Development Workflow Issues
- Always test in-editor before committing
- Use print statements for debugging
- Keep backup saves of working states
- Run validation after major changes

## Platform-Specific (macOS)
- Case-sensitive file system can cause issues
- Check file permissions for asset loading
- Use forward slashes in resource paths
- AVCapture warnings are non-critical

## Phase 1 Specific Lessons

### Mouse Input Handling
- Mouse capture must be triggered by user input
- Use `Input.mouse_mode = Input.MOUSE_MODE_CAPTURED`
- Always provide escape mechanism for mouse release

### Procedural Mesh Generation
- ArrayMesh requires proper vertex/normal/UV array sizing
- Indices must reference valid vertex indices
- Normal calculation is critical for proper lighting

### Group-Based Node Finding
- Add nodes to groups in `_ready()`
- Use `get_tree().get_first_node_in_group("group_name")`
- Fallback to `get_node_or_null()` for optional references

### Export Variables
- Use `@export` for editor-configurable parameters
- Group related exports with comments
- Provide sensible default values

## CI/CD Pipeline Issues

### GitHub Actions Workflow Failures
**Status**: Known issue as of 2025-05-31
**Symptoms**: 
- Container setup fails in GitHub Actions
- Export template configuration issues
- Project import failures in headless mode

**Investigation Steps**:
1. Check container image compatibility: `barichello/godot-ci:4.2.1`
2. Verify Godot version consistency between env vars and container
3. Ensure export templates match Godot version exactly
4. Check project.godot file compatibility with headless import

**Current Status**:
- Fixed version mismatch (GODOT_VERSION: 4.2.1 matches container)
- Workflow still failing despite version fix
- Manual testing in local Godot editor works correctly

**Workarounds**:
- Focus on code-only development workflow
- Manual validation using `godot --headless --quit --validate-project`
- Defer CI/CD troubleshooting to dedicated infrastructure sprint

**Next Steps for Resolution**:
- Investigate export preset configuration requirements
- Consider updating to newer Godot CI container images
- May need custom Docker container for code-only projects
- Add proper error logging to CI workflow steps
