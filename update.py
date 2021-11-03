import os
import shutil
import sys

addon_folder = "CharacterSheet"

def update(addons_path):
    target_path = os.path.join(addons_path, addon_folder)
    if os.path.exists(target_path):
        shutil.rmtree(target_path)
    shutil.copytree(addon_folder, target_path)    

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Specify the path to your addon folder")
        exit()
    update(sys.argv[1])
