#!/bin/bash

# Icons and names
ICONS=(
  "icon_16x16.png:16x16"
  "icon_16x16@2x.png:32x32"
  "icon_32x32.png:32x32"
  "icon_32x32@2x.png:64x64"
  "icon_128x128.png:128x128"
  "icon_128x128@2x.png:256x256"
  "icon_256x256.png:256x256"
  "icon_256x256@2x.png:512x512"
  "icon_512x512.png:512x512"
  "icon_512x512@2x.png:1024x1024"
)

EXTRA_ICONS=(
  "32x32.png:32x32"
  "128x128.png:128x128"
  "128x128@2x.png:256x256"
  "icon.png:512x512"
  "Square30x30Logo.png:30x30"
  "Square44x44Logo.png:44x44"
  "Square71x71Logo.png:71x71"
  "Square89x89Logo.png:89x89"
  "Square107x107Logo.png:107x107"
  "Square142x142Logo.png:142x142"
  "Square150x150Logo.png:150x150"
  "Square284x284Logo.png:284x284"
  "Square310x310Logo.png:310x310"
  "StoreLogo.png:100x100"
)

# Create directory and icons
generate_icons() {
  local src_image=$1
  local build_dir=$2
  local resize=$3
  local output_dir="$build_dir/icon_images"

  mkdir -p "$output_dir"

  for ICON in "${ICONS[@]}"; do
    IFS=":" read -r NAME SIZE <<< "$ICON"
    if [[ "$resize" == "true" ]]; then
      magick "$src_image" -resize "$SIZE" "$output_dir/$NAME"
    else
      magick -size "$SIZE" xc:none "$output_dir/$NAME"
    fi
  done

  echo "Images created at path: $output_dir"
}

# Create extra images
generate_extra_images() {
  local src_image=$1
  local build_dir=$2
  local output_dir="$build_dir/extra_images"

  mkdir -p "$output_dir"

  for ICON in "${EXTRA_ICONS[@]}"; do
    IFS=":" read -r NAME SIZE <<< "$ICON"
    magick "$src_image" -resize "$SIZE" "$output_dir/$NAME"
  done

  echo "Extra images created at path: $output_dir"
}

# Create .icns file
create_icns() {
  local build_dir=$1
  local image_dir="$build_dir/icon_images"

  for ICON in "${ICONS[@]}"; do
    IFS=":" read -r NAME SIZE <<< "$ICON"
    if [[ ! -f "$image_dir/$NAME" ]]; then
      echo "Error: $NAME missing in $image_dir"
      exit 1
    fi
  done

  ICONSET_DIR="$build_dir/icon.iconset"
  mkdir -p "$ICONSET_DIR"

  for ICON in "${ICONS[@]}"; do
    IFS=":" read -r NAME SIZE <<< "$ICON"
    cp "$image_dir/$NAME" "$ICONSET_DIR/"
  done

  iconutil -c icns "$ICONSET_DIR"
  mv icon.icns "$build_dir/"

  if [[ -f "$build_dir/icon.icns" ]]; then
    echo "The .icns was successfully created in $build_dir/icon.icns"
  else
    echo "There was a problem while creating the .icns file."
    exit 1
  fi
}

# Create .ico file
create_ico() {
  local src_image=$1
  local build_dir=$2
  local output_file="$build_dir/icon.ico"

  mkdir -p "$build_dir"
  magick convert "$src_image" -define icon:auto-resize=256,128,64,48,32,16 "$output_file"

  if [[ -f "$output_file" ]]; then
    echo "The .ico file was successfully created in $output_file"
  else
    echo "There was a problem while creating the .ico file."
    exit 1
  fi
}

# Help function
show_help() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  --create-placeholders               Create placeholders"
  echo "  --create-placeholders-from-image    Create placeholders from existing image"
  echo "  --create-extra-images               Create extra images"
  echo "  --create-icns                       Create .icns from images"
  echo "  --create-ico                        Create .ico file from image"
  echo "  --help                              Show this help"
}

# Check arguments
if [[ $# -eq 0 ]]; then
  show_help
  exit 0
fi

# Create build directory if it doesn't exist
BUILD_DIR="$(pwd)/build"
mkdir -p "$BUILD_DIR"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --create-placeholders)
      generate_icons "" "$BUILD_DIR" "false"
      shift
      ;;
    --create-placeholders-from-image)
      if [[ -z "$2" ]]; then
        echo "Usage: $0 --create-placeholders-from-image <imagepath>"
        exit 1
      fi
      generate_icons "$2" "$BUILD_DIR" "true"
      shift 2
      ;;
    --create-extra-images)
      if [[ -z "$2" ]]; then
        echo "Usage: $0 --create-extra-images <imagepath>"
        exit 1
      fi
      generate_extra_images "$2" "$BUILD_DIR"
      shift 2
      ;;
    --create-icns)
      create_icns "$BUILD_DIR"
      shift
      ;;
    --create-ico)
      if [[ -z "$2" ]]; then
        echo "Usage: $0 --create-ico <imagepath>"
        exit 1
      fi
      create_ico "$2" "$BUILD_DIR"
      shift 2
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done