import base64
import socket
from io import BytesIO
# import cv2
import cv2
import waitress
import face_recognition
import numpy, json
from flask import Flask, request, jsonify
from PIL import Image

recognizer = Flask(__name__)


def convert_byte_to_the_image(incomingBytes):
    # YOU CAN USE BOTH OF THESE OPTIONS BELOW (I AM USING 2nd Option):
    # 1 Option:
    img = cv2.imdecode(numpy.frombuffer(buffer=incomingBytes, dtype=numpy.uint8), cv2.IMREAD_COLOR)
    image = numpy.asarray(img)
    return image
    # -----------------------------------------------------------------------
    # 2 Option:
    # byte_data = BytesIO(incomingBytes)
    # return face_recognition.load_image_file(incomingBytes)

    # image = Image.frombytes('RGB', (400, 400), incomingBytes)
    # return image


@recognizer.route('/compare_faces', methods=["POST"])
def compare_faces():
    if request.method == "POST":
        try:
            print("REQUESTED FOR COMPARING")
            # Getting JSON and decoding it to dictionary (Map). Assuming that the JSON has keys named:
            # 'image': which has image bytes,
            # 'blob': that has known encoding
            _data = request.get_json()
            # CONVERTING data from the type 'str' to the type 'bytes'
            _data_image_bytes = base64.b64decode(_data['image'])

            # CONVERTING 'bytes' to the image
            _data_image = convert_byte_to_the_image(_data_image_bytes)

            face_locations_from_image = face_recognition.face_locations(_data_image)

            # Find face encodings and take first face encoding from the image
            face_encodings_from_image = face_recognition.face_encodings(_data_image, face_locations_from_image)

            # 1.Decoding data from 'str' to the type 'bytes' with writing: "base64.b64decode(_data['blob'])"
            # 2.Against decoding the type 'bytes' to the 'str'
            # 3.In result, we will get faceID with type 'str' with writing: ".decode('utf-8')"
            _blob = base64.b64decode(_data['blob']).decode('utf-8')

            # Decoding _blob which we got, from the type 'str' to the type 'bytes'
            _blob = base64.b64decode(_blob)

            # Converting  'bytes' to the encoding from blob
            known_encoding_from_blob = numpy.frombuffer(_blob, dtype=numpy.float64)

            # Comparing face encodings and returning result
            result = face_recognition.compare_faces(face_encodings_from_image, known_encoding_from_blob, tolerance=0.6)

            # result = list(numpy.linalg.norm(known_encoding_from_blob - face_encodings_from_image, axis=1) <= 0.5)
            if True in result:
                is_valid = True
            else:
                is_valid = False
            return jsonify({'is_empty': False, 'is_valid': is_valid}), 201
        except Exception as _:
            return jsonify({'is_empty': True, 'is_valid': False}), 201



@recognizer.route('/convert_image_to_the_blob', methods=["POST"])
def convert_image_to_the_blob():
    if request.method == "POST":
        try:
            print("REQUESTING FOR CONVERTING")

            # Getting JSON and decoding it to dictionary (Map). Assuming that the JSON has key:
            # 'image': which has image bytes
            data = request.get_json()

            # CONVERTING data from the type 'str' to the type 'bytes'
            data = base64.b64decode(data['image'])
            # data = base64.b64decode(data)

            # CONVERTING bytes to the image
            image = convert_byte_to_the_image(data)

            # Find face encodings and take first face encoding from the image
            face_encoding = face_recognition.face_encodings(image)[0]

            # CONVERTING face_encoding TO SERIALIZABLE TYPE FOR JSON
            encoded_data = base64.b64encode(face_encoding.tobytes()).decode('utf-8')

            return json.dumps({'blob': encoded_data, 'is_valid': True}), 201
        except Exception as _:
            return json.dumps({'is_valid': False}), 201

if __name__ == "__main__":
    ip = "192.168.100.13"
    PORT = 2363
    # recognizer.run(host=str(ip), port=2363, debug=False)

    # Running through WSGI server for production version
    print(f"Listening on {ip}:{PORT}...")
    waitress.serve(app=recognizer, host=str(ip), port=PORT)
