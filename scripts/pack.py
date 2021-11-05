import common
import copy
import argparse
import shutil

def pack(target_folder):
    temp_path = f"{target_folder}/{common.addon_folder}"
    copy.copy(temp_path)
    shutil.make_archive(
        f"release/{common.addon_folder}",
        "zip",
        temp_path,
    )
    shutil.rmtree(temp_path)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description =
        "Compresses the addon to a zip file for release."
    )
    args = parser.parse_args()
    pack(common.output_folder)
