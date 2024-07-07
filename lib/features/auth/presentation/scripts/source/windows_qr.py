import sys

import cv2
from pyzbar.pyzbar import decode


def read_qr_code(image_path):
    img = cv2.imread(image_path)
    if img is not None:
        decoded_object = decode(img)[0]
        print(f'{decoded_object.data.decode("utf-8")}')


if __name__ == "__main__":
    if len(sys.argv) > 1:
        read_qr_code(sys.argv[1])
