#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#define PORT 8080
#define BLOCK_SIZE 20
#define MAX_LINE 100

int main()
{
	int sockfd,i;
	struct sockaddr_in serv_addr;
	char buff[BLOCK_SIZE],fname[MAX_LINE];
	sockfd = socket(AF_INET,SOCK_STREAM,0);
	if(sockfd<0)
	{
		printf("socket creation failed");
		exit(1);
	}
	
	serv_addr.sin_family = AF_INET;
	inet_aton("127.0.0.1",&serv_addr.sin_addr);
	serv_addr.sin_port = htons(PORT);
	
	if(connect(sockfd,(struct sockaddr *)&serv_addr,sizeof(serv_addr))<0)
	{
		printf("Connection failed");
		exit(1);
	}
	printf("Connected to server....\n");
	
	printf("Enter file name : ");

	scanf("%s",fname);
	

	
	
	send(sockfd,fname,strlen(fname)+1,0);
	char code;
	
	recv(sockfd,&code,sizeof(char),0);
	

	if(code == 'E')
	{
		printf("File Not Found\n");	
		close(sockfd);
		exit(0);
	}
	
	else
	{
          int fd = open("output.txt",O_WRONLY|O_CREAT|O_TRUNC,S_IRWXU);
		int fsize;
		char f_size[10];
		
		int nbytes_recv = recv(sockfd,f_size,sizeof(f_size),MSG_WAITALL);
		if(nbytes_recv<0)
		{
			printf("Unable to receive from server");
			exit(1);
		}
		
		
		fsize = atoi(f_size);
		
		
		int comp_block = fsize/BLOCK_SIZE;
		for(i=0;i<comp_block;i++){
			bzero(buff,BLOCK_SIZE);
		
			recv(sockfd,buff,BLOCK_SIZE,MSG_WAITALL);
		
			write(fd,buff,BLOCK_SIZE);
		}
	
		int last_block = fsize % BLOCK_SIZE;
		
		if(last_block == 0)
		{
			if(fsize==0)
				printf("The file transfer is successful. Total number of blocks received = %d, Last block size = %d\n",comp_block,last_block);
		    else
		    	printf("The file transfer is successful. Total number of blocks received = %d, Last block size = %d\n",comp_block,BLOCK_SIZE);
		}
		
		else
		{
			
			bzero(buff,BLOCK_SIZE);
			
			recv(sockfd,buff,last_block,MSG_WAITALL);
			
			write(fd,buff,last_block);
			printf("The file transfer is successful. Total number of blocks received = %d, Last block size = %d\n",comp_block+1,last_block);
		}
	
		close(fd);
		close(sockfd);
		
	}
	return 0;
}
