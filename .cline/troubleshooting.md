# Troubleshooting Guide

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

## Development Workflow Issues
- Always test in-editor before committing
- Use print statements for debugging
- Keep backup saves of working states

## Platform-Specific (macOS)
- Case-sensitive file system can cause issues
- Check file permissions for asset loading
- Use forward slashes in resource paths
