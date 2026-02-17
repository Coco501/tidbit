<div align="center">
  <img src="https://raw.githubusercontent.com/coco501/images/main/tidbit_small.png" alt="tidbit">
</div>

#

tidbit is a lightweight command-line tool that keeps your notes organized and instantly accessible  

## Install
After cloning the repository, run the install script from the root of the project  
```
./install.sh
```
- installs `fzf` for interactive fuzzy searching  
- adds `tidbit` to your PATH so it can be ran from anywhere  

## Usage
Run tidbit in interactive mode with fzf (Ctrl+J and Ctrl+K for file selection)  
```
tidbit
```

Open a subject's `tidbit.md` file  
```
tidbit [subject]
```

Open a specific `.md` file  
```
tidbit [subject] [file]
```

## Example Commands
`tidbit vim` - opens subjects/vim/tidbit.md  
`tidbit vim motions` - opens subjects/vim/motions.md  

## Personalize
Add as many tidbits as you want!  
I recommend making your own fork of this repository for easy version control  

