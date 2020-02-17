import socket, cv2, numpy

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
address = ('', 2222)
sock.bind(address)
sock.listen()

print("server starts. {}".format(address))

capture = cv2.VideoCapture(0)

capture.set(5, 30)

while True:
    print("wait for accept.")
    client, address = sock.accept()
    print("new conn.")

    while True:
        try:
            recv_str = client.recv(4).decode('utf-8')
            if  recv_str != "RECV":
                print("Attack detected. ({})".format(recv_str))
                break

            ret, frame = capture.read()

            encode_param = [cv2.IMWRITE_JPEG_QUALITY, 95]
            result, imgencode = cv2.imencode('.jpg', frame, encode_param)
            
            data = numpy.array(imgencode)
            stringData = data.tostring()
            
            client.send( str(len(stringData)).encode('utf-8').ljust(8))
            client.send( stringData )
            print(len(stringData))
        except:
            break

    # length = client.recv(16)
    # data = client.recv(int(length))
    # client.send("RECV".encode('utf-8'))