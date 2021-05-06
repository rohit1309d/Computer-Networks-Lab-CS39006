#include <stdio.h> 
#include <stdlib.h> 
#include <unistd.h> 
#include <string.h> 
#include <sys/types.h> 
#include <sys/socket.h> 
#include <arpa/inet.h> 
#include <netinet/in.h> 

#define PORT 8080 
#define MAXLINE 1024 

int main() { 
	int sockfd; 
	char buffer[MAXLINE]; 
	struct sockaddr_in servaddr; 

	if ( (sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0 ) { 
		perror("socket creation failed"); 
		exit(EXIT_FAILURE); 
	} 

	memset(&servaddr, 0, sizeof(servaddr)); 
	
	servaddr.sin_family = AF_INET; 
	servaddr.sin_port = htons(PORT); 
	servaddr.sin_addr.s_addr = INADDR_ANY; 
	
	int n, len; 

	printf("Enter file name : ");
	char fname[MAXLINE];
	scanf("%[^\n]%*c", fname);
	sendto(sockfd, (const char *)fname, strlen(fname), MSG_CONFIRM, (const struct sockaddr *) &servaddr, sizeof(servaddr));

	n = recvfrom(sockfd, (char *)buffer, MAXLINE, MSG_WAITALL, (struct sockaddr *) &servaddr, &len); 
	buffer[n] = '\0'; 
	
	if (strcmp(buffer,"WRONG_FILE_FORMAT") == 0)
	{
		printf("Wrong file format\n");
		return 0;
	}
	else if (strcmp(buffer,"FILE_NOT_FOUND") == 0)
	{
		printf("File Not Found\n");
		return 0;
	}

	FILE * fp;
	char outname[MAXLINE] = "client_";
	strcat(outname, fname);
	fp = fopen(outname, "w");
	printf("File %s is created\n", outname);

	char word[MAXLINE];
	strcpy(word,"WORD");
	int i = 1;

	while(1){

		char is[10];
		char msg[MAXLINE];

		sprintf(is, "%d", i);
		strcpy(msg, word);
		strcat(msg, is);

		sendto(sockfd, (const char *)msg, strlen(msg), MSG_CONFIRM, (const struct sockaddr *) &servaddr, sizeof(servaddr)); 
		printf("%s is sent.\n", msg); 
			
		n = recvfrom(sockfd, (char *)buffer, MAXLINE, MSG_WAITALL, (struct sockaddr *) &servaddr, &len); 
		buffer[n] = '\0'; 
		
		if(strcmp(buffer,"END") == 0)
			break;
			
		fprintf(fp,"%s\n", buffer);
		i++;
	}

	fclose(fp);
	close(sockfd); 

	return 0; 
} 
