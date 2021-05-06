#include <bits/stdc++.h>
#include <unistd.h> 
#include <netdb.h>
#include <netinet/in.h> 
#include <arpa/inet.h> 
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h> 
#include <sys/select.h> 
#include <sys/time.h> 
#include <fcntl.h>
#include <errno.h> 
using namespace std;
#define BUFFER_SIZE 1024



pair <string, string> name_message(char * buffer) 
{
   int length = strlen(buffer);
   
   string name;
   string message;
   bool flag = false;
   for (int i = 0; i <length; i++) 
   {
   	if(buffer[i]=='\n')
   		continue;
      if (flag == false) 
      {
         if (buffer[i] == '/') {
            flag = true;
            continue;
         }
         name.push_back(buffer[i]);
      } 
      else message.push_back(buffer[i]);
   }
   return make_pair(name, message);
}

int main(int argc, char ** argv) {   
   
    ifstream fname;
    fname.open("peers.txt");
    map <string, pair<string,string>> mp;  
   
    string name, ip_ad, port;
    while (fname >> name) 
    {
        fname >> ip_ad >> port;       
        mp[name]=make_pair(ip_ad,port);
    }
    fname.close();
    printf("Available Peers\n" );
   
    for (pair < string, pair<string,string>> d : mp) 
        cout << d.first<< " ( " << d.second.first << " : " << d.second.second << " )" << endl; 
    
    if (argc != 2) 
	{
	  printf("Invalid input, Enter only one port number");
	  exit(1);
	}
	fd_set readset, tempset;
	
   	int maxfd;
   	int portno;
	
	portno = atoi(argv[1]);
    int srvsock;
	
	srvsock = socket (AF_INET, SOCK_STREAM, 0);
	if (srvsock <0) 
	{
		printf("ERROR opening socket");
		exit(1);
	}
	int peersock, j, result;
	socklen_t len;	
	
	char buffer[BUFFER_SIZE + 1];
	struct sockaddr_in serveraddr;
	char buf[BUFFER_SIZE];
	
	int flag = 1;
	setsockopt (srvsock, SOL_SOCKET, SO_REUSEADDR, (const void *) &flag, sizeof (int));
	
	bzero((char *) &serveraddr, sizeof (serveraddr));

	serveraddr.sin_family = AF_INET;	
	serveraddr.sin_addr.s_addr = htonl (INADDR_ANY);	
	serveraddr.sin_port = htons ((unsigned short) portno);	
	if (bind (srvsock, (struct sockaddr *) &serveraddr, sizeof (serveraddr)) <0)
	{
		printf("Address already in use\n");
		exit(1);
    } 	
	if (listen(srvsock, 5) <0) 
	{
		printf ("ERROR on listen\n");
		exit(1);
	}
	printf ("\nStart a conversation.\n");
	string myName;
	int check=0;	

	for (pair <string, pair<string,string>> d: mp) 
	{
		if (d.second.first =="127.0.0.1" && stoi (d.second.second) == atoi (argv[1])) 
		{
			myName = d.first;
			check = 1;
			cout <<"You are now " << d.first << "." << endl << "enter a message" << endl;
			
			break;
		}
	}
	if (check == 0) 
	{
		printf ("Your port number is not in the list\n");
		exit(0);
	}


	struct timeval tv;
	FD_ZERO (&readset);
	FD_SET (srvsock, &readset);
	FD_SET (0, &readset);
	maxfd = srvsock;
	tv.tv_sec =100;
	tv.tv_usec = 0;
	
	while(1){
	  memcpy (&tempset, &readset, sizeof (tempset));
	  
	  result = select (maxfd + 1, &tempset, NULL, NULL, &tv);

	  if(result==0)
	  {
	  	printf("Time out, exiting........\n");
	  	exit(1);
	  }
	   if (result < 0 && errno != EINTR) 
	   {
	  		printf("Error in select \n");
	  		exit(1);
	  		
	  } 
	  else if (result > 0)
	   {
		 if (FD_ISSET(srvsock, &tempset)) 
		 {
			len = sizeof(serveraddr);
			peersock = accept (srvsock, (struct sockaddr * ) &serveraddr, &len);
			if (peersock < 0)
			 {
				printf("Error in accept \n");
	  			exit(1);
			} 
			else 
			{
				FD_SET (peersock, &readset);
				maxfd = (maxfd <peersock) ? peersock : maxfd;
			}
			FD_CLR (srvsock, &tempset); 
		 }
		 
		 if (FD_ISSET (0, &tempset)) 
		 {
		 	memset(buf,'\0',BUFFER_SIZE);
		 	read (0, buf, BUFFER_SIZE);
		 	
			
			int sockfd, portno2, n;
			struct sockaddr_in serveraddr2;
			struct hostent * server;
			char hostname[20];
			pair <string, string> personMessage2 = name_message (buf);
            auto itr = mp.find(personMessage2.first);
            if (itr == mp.end())
            {
			cout << "peer does not exist\n";
			continue;
			}
			strcpy(hostname,itr->second.first.c_str());
			portno2 = stoi(itr->second.second);
			cout << "Sending to : (" << itr->first << ")" << endl;
			tv.tv_sec =100;
			tv.tv_usec = 0;


			

			sockfd = socket (AF_INET, SOCK_STREAM, 0);
			if (sockfd < 0) 
			{
				printf("ERROR opening the socket");
				exit(0);
			}

			
			server = gethostbyname (hostname);
			if (server == NULL) 
			{
				printf("No such host\n");
				exit(0);
			}
			
			bzero ((char * ) &serveraddr2, sizeof (serveraddr2));
			serveraddr2.sin_family = AF_INET;
			bcopy ((char *) server -> h_addr, (char *) &serveraddr2.sin_addr.s_addr, server -> h_length);
			serveraddr2.sin_port = htons (portno2);

			if (connect (sockfd, (struct sockaddr *) &serveraddr2, sizeof (serveraddr2)) <0) 
			{
				printf("Peer is not available now\n");
				continue;
			}
			
			pair <string, string> getpm = name_message(buf);

			memset(buf,'\0',BUFFER_SIZE);
			strcpy(buf,myName.c_str());
			strcat(buf,"/");
			strcat(buf,getpm.second.c_str());

			int err = write (sockfd, buf, strlen (buf));
			if (err < 0) 
			{
				printf("ERROR writing to socket");
				exit(0);
			}
			close (sockfd);
			continue;
		 }

		 for (j = 1; j <= maxfd; j++) 
		 {
			if (FD_ISSET(j, &tempset)) 
			{
				do 
				{
					result = recv (j, buffer, BUFFER_SIZE, 0);
				} while (result == -1 && errno == EINTR);

				if (result> 0) 
				{
					buffer[result] = '\0';
					pair <string, string> personMessage1 = name_message(buffer);
					cout << personMessage1.first.c_str () << " : " << personMessage1.second << endl;
				} 
				else if (result == 0) {
					close (j);
					FD_CLR (j, &readset);
				} 
				else {
					printf("Error in recv \n");
	  					exit(1);
				}
			} 
		 } 
	  } 
	} 
	return 0;
}

