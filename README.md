<div align="center">
  <img src="https://raw.githubusercontent.com/coco501/images/main/tidbit_small.png" alt="tidbit logo">
  <p><b>tidbit</b> - easy note-taking</p>
</div>

## About
<b>tidbit</b> is a light-weight command-line tool that I made in response to my increasing frustration from dozens of scattered note files

Highlights:
- never lose your notes
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
Run tidbit in interactive mode with fzf (Ctrl+J and Ctrl+K for file selection):
```
tidbit
```

<br>

Open a subject's `tidbit.md` file:
```
tidbit [subject]

tidbit vim 
- opens subjects/vim/tidbit.md
```

<br>

Open a subject's specific `.md` file:
```
tidbit [subject] [file]

tidbit vim motions 
- opens subjects/vim/motions.md
```
