#include "opencv2/opencv.hpp"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <strings.h>
#include <sys/socket.h>
#include <resolv.h>
#include <arpa/inet.h>
#include <errno.h>
#include <iostream>


#define MY_PORT		2222
#define MAX_BUF		1024

using namespace std;
using namespace cv;

int main(int argc, char** argv)
{   
    VideoCapture cap;
    if(!cap.open(0))
        return 0;
    cap.set(3, 640);
    cap.set(4, 360);
    int sockfd;
	struct sockaddr_in self;
	char buffer[MAX_BUF];

	/** Create streaming socket */
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
	{
		perror("Socket");
		exit(errno);
	}

	/** Initialize address/port structure */
	bzero(&self, sizeof(self));
	self.sin_family = AF_INET;
	self.sin_port = htons(MY_PORT);
	self.sin_addr.s_addr = INADDR_ANY;

	/** Assign a port number to the socket */
    if (bind(sockfd, (struct sockaddr*)&self, sizeof(self)) != 0)
	{
		perror("socket:bind()");
		exit(errno);
	}

	/** Make it a "listening socket". Limit to 20 connections */
	if (listen(sockfd, 20) != 0)
	{
		perror("socket:listen()");
		exit(errno);
	}

	/** Server run continuously */
	while (1)
	{	int clientfd;
		struct sockaddr_in client_addr;
		unsigned int addrlen=sizeof(client_addr);

		/** accept an incomming connection  */
		clientfd = accept(sockfd, (struct sockaddr*)&client_addr, &addrlen);
		printf("%s:%d connected\n", inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));

		while(recv(clientfd, buffer, MAX_BUF, 0) > 0){
		Mat frame;
        cap >> frame;
        vector<uchar> vec;
        imencode(".jpg", frame, vec);
        imshow("CAM", frame);
		cout<<vec.size()<<endl;
		string length_str = to_string(vec.size());
		length_str.resize(16);
		/** Echo back the received data to the client */
		send(clientfd, length_str.c_str(), 16, 0);
		send(clientfd, vec.data(), vec.size(), 0);
		}
		//send(clientfd, buffer, recv(clientfd, buffer, MAX_BUF, 0), 0);

		/** Close data connection */
		close(clientfd);
	}

	/** Clean up */
	close(sockfd);
	return 0;
}
