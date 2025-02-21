# App Icon Builder

## How it works

This project uses image magick to create all the icons used for your [Tauri](https://tauri.app/) desktop app.
It starts with a single `icon.png` and creates all the sizes formats required.

🎨 Fun fact: This icon generator is like a digital photocopier on steroids - it takes one image and turns it into a whole family of perfectly sized icons. It's basically running a cloning facility, but for pixels!

## Building Icons

1. First ensure you have the required dependancies, use [`brew bundle`](https://github.com/Homebrew/homebrew-bundle) to install anything required.
2. Run the build `./build.sh`
3. Finder will open with all your generated Icons.

🪄 Behind the scenes, [ImageMagick](https://imagemagick.org/) is performing what we like to call "icon gymnastics" - stretching, shrinking, and contorting your original image into every conceivable size. No pixels were harmed in the process (well, maybe a few).

💡 Pro tip: If you're wondering why we need so many icon sizes, it's because different platforms are like picky eaters - Windows wants its icons one way, macOS another, and Linux just wants to be different. It's like cooking the same meal in 12 different ways to please everyone at the dinner table!
