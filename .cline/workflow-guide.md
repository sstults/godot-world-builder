# Cline Workflow Automation Guide

## Streamlined Development Process

### 1. Session Startup (30 seconds)
Instead of explaining everything, just say:
```
Read project-context.md and help me with [task]
```

### 2. Task-Specific Quick Starts

**New Feature Development:**
```
Context: project-context.md | Task: Implement [feature] | Patterns: development-patterns.md | Update: knowledge base
```

**Bug Investigation:**
```
Context: project-context.md | Debug: [issue] | Check: troubleshooting.md | Document: solution
```

**Code Review/Improvement:**
```
Context: project-context.md | Review: [file/system] | Apply: development-patterns.md | Optimize: performance
```

**Phase Transition:**
```
Context: project-context.md + milestone-reviews.md | Plan: next phase | Update: project status
```

### 3. Knowledge Base Maintenance Commands

**Update Progress:**
```
Update milestone-reviews.md with completed [task] and lessons learned
```

**Add New Pattern:**
```
Document [new pattern/solution] in development-patterns.md following existing format
```

**Record Issue:**
```
Add [problem + solution] to troubleshooting.md
```

## File Organization for AI Efficiency

### High-Priority Files (Read First)
1. `.cline/project-context.md` - Current status and priorities
2. `.cline/milestone-reviews.md` - Progress and lessons learned
3. `.cline/development-patterns.md` - Established code patterns

### Context Files (Read When Relevant)
- `.cline/godot-learnings.md` - Godot-specific knowledge
- `.cline/troubleshooting.md` - Known issues and solutions
- `.cline/procedural-gen-notes.md` - Generation algorithm details
- `.cline/performance-notes.md` - Optimization insights

### Implementation Files (Examine When Coding)
- `/scripts/*.gd` - Current implementation
- `/scenes/*.tscn` - Scene structure
- `project.godot` - Project configuration

## Efficient Communication Patterns

### ✅ Good Prompts (Clear, Contextual, Actionable)
```
Read project-context.md. Implement crafting system foundation following patterns in development-patterns.md. Priority: basic item creation and inventory storage.
```

### ❌ Avoid (Too Much Re-explanation)
```
We're building a Godot game with procedural terrain, and we have a player that can move around, and we've built a camera system, and now I want to add crafting...
```

### ✅ Status Updates
```
Update project-context.md: Phase 2 complete. Next: Phase 3 - UI and Polish. Add crafting system completion to milestone-reviews.md.
```

### ✅ Pattern Recognition
```
Extract the [specific implementation] pattern and add to development-patterns.md for future reference.
```

## GitHub Integration Workflow

### Issue-Driven Development
1. Create GitHub issue using template
2. Reference issue in Cline prompts
3. Update knowledge base during implementation
4. Close issue with knowledge base updates

### Branch Strategy
```
Context: project-context.md | Branch: feature/[name] | Issue: #[number] | Implement: [feature]
```

## Time Savings Summary

| Workflow | Before | After | Time Saved |
|----------|--------|--------|-------------|
| Context Setting | 2-3 minutes | 30 seconds | 80% |
| Finding Patterns | Manual search | Direct reference | 90% |
| Progress Tracking | Re-explain status | Read context file | 85% |
| Knowledge Sharing | Repeat learnings | Reference knowledge base | 95% |

## Advanced: Custom Cline Instructions

For even more efficiency, create custom instructions for Cline:

1. **Always read `.cline/project-context.md` first**
2. **Reference knowledge base files before asking for clarification**
3. **Update knowledge base after every implementation**
4. **Follow established patterns from `development-patterns.md`**
5. **Document new patterns and solutions**

This reduces your interaction from explanation → implementation to just: task specification → implementation.
