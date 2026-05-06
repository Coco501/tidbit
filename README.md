<div align="center">
  <img src="https://raw.githubusercontent.com/coco501/images/main/tidbit_small.png" alt="tidbit logo">
  <p><b>tidbit</b> - easy note-taking</p>
</div>

## About
<b>tidbit</b> is a light-weight command-line tool that I made in response to my increasing frustration from dozens of scattered note files

- never lose track of your notes
- save the commands you always forget
- simple organization, instant access
- interactive fuzzy searching & previewing (with [fzf](https://github.com/junegunn/fzf))
- usable by a 3-year-old

## Install
Run the install script from the root of the project  
```
./install.sh
```
- installs [fzf](https://github.com/junegunn/fzf) for interactive fuzzy searching
- adds tidbit to your PATH

## Usage
```
tidbit                  # interactive mode with fzf (Ctrl+J/K to navigate)
tidbit [subject]        # open subjects/[subject]/tidbit.md
tidbit [subject] [file] # open subjects/[subject]/[file].md
```
