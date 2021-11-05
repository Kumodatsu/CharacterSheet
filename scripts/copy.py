import common
import argparse
import os
import shutil

def copy(dest_path):
    target_path = os.path.join(dest_path, common.addon_folder)
    if os.path.exists(target_path):
        shutil.rmtree(target_path)
    shutil.copytree(common.addon_folder, target_path)    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description =
        "Copies the addon to the specified folder."
    )
    parser.add_argument(
        "path",
        help = "The folder to copy the addon to.",
        type = str
    )
    args = parser.parse_args()
    copy(args.path)
