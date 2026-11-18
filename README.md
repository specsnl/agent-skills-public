# specsnl/agent-skills-public

Specs agent-skills meant for the public sector (govnl).

## Installation instructions

Claude: `claude plugin marketplace add specsnl/agent-skills-public`  
Copilot: `copilot plugin marketplace add specsnl/agent-skills-public`

The marketplace namespace is `specs-public`. So after adding this marketplace you will be able to install specific
plugins using:

- `claude plugin install <plugin>@specs-public`; or
- `copilot plugin install <plugin>@specs-public`.

## Plugins

| Plugin Name                     | Description                                                                                                                                    |
|---------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
| github-releases@specs-public    | Sort a GitHub release's changes into a grouped "What's Changed" list and an issue list, and write Dutch release notes and changelogs from them |
| product-management@specs-public | Create a Product Definition from your product documents and validate proposed features against it                                              |

## Reference these plugins from another marketplace

Each plugin carries its own `version` in `plugins/<plugin>/.claude-plugin/plugin.json`, so another marketplace can
list a plugin from this repository without tracking its version. Leave `version` out of the entry:

```json
{
    "name": "github-releases",
    "source": {
        "source": "git-subdir",
        "url": "specsnl/agent-skills-public",
        "path": "plugins/github-releases"
    }
}
```

## Tasks

Check out the complete list using `task --list`.
