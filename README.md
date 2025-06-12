# virtualfish-uvenv

> [uv](https://docs.astral.sh/uv/)-based virtual environments in a **centralized location** with [virtualfish](https://github.com/justinmayer/virtualfish)

[**uv**](https://docs.astral.sh/uv/) is a fast Python package and project manager, an otherwise great tool that [does not yet support storing virtualenvs in a centralized location](https://github.com/astral-sh/uv/issues/1495).
Instead it creates virtualenvs in `.venv` folders in the project root folder itself, which makes the virtualenvs only available for that single project or at least hard to re-use from other folders.

[**virtualfish**](https://github.com/justinmayer/virtualfish) is an amazing Python virtualenv manager for the [fish shell](https://fishshell.com/), an otherwise great tool that [does not yet support the management of environments via uv](https://github.com/justinmayer/virtualfish/issues/248).
It uses `virtualenv` instead and while `uv` is able to use any virtual environment, even ones created with `virtualenv`, this does not take advantage of `uv`'s [sync and lock file mechanics](https://docs.astral.sh/uv/guides/projects/).

**This plugin** is an opinionated piece of software that allows you to *keep using your virtualfish workflow* with virtualenvs in *a centralized location* but also adds *uv environments* to that, allowing you to use *all features of `uv`*.
Your old environments *will keep working* and you can mix and match `uv` managed environments (with `project.toml` and `uv.lock` files enabling locking and syncing) as well as `virtualenv`'s environments.

The virtual environments created by this plugin will also be compatible with `virtualfish` and other tools that expect the *normal layout for virtualenvs*.


## Setup

0. Make sure to have [fish shell](https://fishshell.com/) version 3.7 or newer
1. Have [uv installed](https://docs.astral.sh/uv/getting-started/installation/)
2. Have [virtualfish installed](https://github.com/justinmayer/virtualfish) (e.g., with `uv tool install virtualfish; vf install`)
    * It is recommended to enable the `auto_activation` and potentially `compat_aliases` [virtualfish plugins](https://virtualfish.readthedocs.io/en/latest/plugins.html)
3. Install this plugin with [Fisher](https://github.com/jorgebucaran/fisher): `fisher install icezyclon/virtualfish-uvenv`
4. Create and use a new `uv` managed environment, see [usage](#usage)


## Usage

The **old** workflow would be to create a new virtual environment at `$VIRTUALFISH_HOME/myenv` with `virtualfish` like so:

```fish
vf new myenv -p (which python3.13)
# or if you have compat_aliases enabled
mkvirtualenv myenv -p (which python3.13)
```

The **new** workflow for creating a new `uv` *project AND environment* at `$VIRTUALFISH_HOME/myenv` is:

```fish
mkuvenv myenv -p 3.13
```

Apart from the new creation command, **everything else stays the same**!
You can use `virtualfish` to activate, delete, list or otherwise manage your `uv` and regular enironments:

```fish
# ACTIVATE ENVIRONMENT
vf activate myenv 
# or if you have compat_aliases enabled
workon myenv

# LIST ENVIRONEMENTS
vf ls
# DELETE ENVIRONMENTS
vf rm <name*>
# AUTO ACTIVATION (if the auto_activation plugin is installed)
cd folder/that/should/always/use/myenv
vf connect
```

Once a `uv`-project-environment is activated, `uv` will automatically use that environment for all operations:

```fish
uv add tqdm pre-commit
uv sync
uv pip list
uv tree
```

You do *not* have to invoke `uv` to run tools in the activated environment as usual:

```fish
uv add pre-commit
which pre-commit
# ~/.virtualenvs/bin/pre-commit
```

Instead of `pip` use `uv pip` to install dependencies, or better, if you want to actually add and lock the dependencies use `uv add` because otherwise `uv sync` will remove dependencies that were only installed with `uv pip` instead of added with `uv add`.

Finally, other tools (like editors) can use/source the environment as usual and do not have to concern themself with `uv`.


## Settings

| Variable                | Default | Descrption                                        |
| ----------------------- | ------- | ------------------------------------------------- |
| UVENV_ECHO_ACTIVATION   | `true`  | Whether to print when a virtualenv is activated   |
| UVENV_ECHO_DEACTIVATION | `false` | Whether to print when a virtualenv is deactivated |

## FAQ

### When should I use this plugin?

If you want fully managed `uv` project (with `pyproject.toml` and `uv.lock` files) but **at a centralized location** AND you want to keep using `virtualfish` for managing/activating your environments.

### When should I *not* use this plugin?

If any of these apply:
* You don't use `uv`
* You just want to use `uv` for existing environments but don't need/want `pyproject.toml` and `uv.lock` files for your environment
* You don't use `virtualfish`
* You don't need/want your environments at a centralized location and are ok with having them in `.venv` folders per project

But maybe you should think about it 😉

### What happens to my old virtualenvs?

You keep them and the plugin will differentiate between `uv` managed and regular environments.

### Can I still create normal virtualenvs?

Yes, just type `vf new`, then Ctrl+Space, then followed by the name and arguments as usual.

### What happens under the hood on activation?

The [plugin](conf.d/virtualfish-uvenv.fish) hooks into [virtualfish events](https://virtualfish.readthedocs.io/en/latest/extend.html) to detect when an environment is activated and also sets the [uv variables](https://docs.astral.sh/uv/reference/environment/#uv_project) `UV_PROJECT $VIRTUAL_ENV` and `UV_PROJECT_ENVIRONMENT .` therefore using the `pyproject.toml` at `$VIRTUAL_ENV` with a flat .venv (so `bin` is directly in `$VIRTUAL_ENV`)

### What happens under the hood on creation?

Checkout [`mkuvenv.fish`](functions/mkuvenv.fish) for the exact commands for initializing the project and environment.


## License

[MIT](LICENSE)

