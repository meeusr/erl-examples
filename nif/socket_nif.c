#include "erl_nif.h"
#include <sys/socket.h>
#include <netinet/in.h>

static ERL_NIF_TERM sock_socket_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    int port, sock;
    struct sockaddr_in sock_addr;

    if (!enif_get_int(env, argv[0], &port)) {
	return enif_make_badarg(env);
    }

    sock = socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP);

    sock_addr.sin_family = AF_INET;
    sock_addr.sin_port = htons(port);
    sock_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    if (bind(sock,(struct sockaddr*)&sock_addr,sizeof(sock_addr)) != 0) {
	close(sock);
	return enif_make_badarg(env);
    }
    return enif_make_int(env, sock);
}

static ERL_NIF_TERM sock_send_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    int sock;
    struct sockaddr_in sock_addr;
    char *data = "TEST\n";
    struct sockaddr_in destination;

    if (!enif_get_int(env, argv[0], &sock)) {
        return enif_make_badarg(env);
    }

    destination.sin_family = AF_INET;
    destination.sin_port = htons(9000);
    inet_pton(AF_INET,"127.0.0.1",&destination.sin_addr.s_addr);
    sendto(sock,data,5,0,(struct sockaddr*)&destination,sizeof(destination));

    return enif_make_int(env, sock);
}

static ERL_NIF_TERM sock_loopback_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    int ret,sock;
    socklen_t addr_len;
    struct sockaddr_in sock_addr;
    char data[2000];
    struct sockaddr_in source;
    
    if (!enif_get_int(env, argv[0], &sock)) {
        return enif_make_badarg(env);
    }
    
    recvfrom(sock,data,sizeof(data),0,(struct sockaddr*)&source,&addr_len);
    ret = sendto(sock,data,5,0,(struct sockaddr*)&source,addr_len);

    return enif_make_int(env, ret);
}


static ERL_NIF_TERM sock_close_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    int sock, ret;
    if (!enif_get_int(env, argv[0], &sock)) {
	return enif_make_badarg(env);
    }
    ret = close(sock);
    return enif_make_int(env, ret);
}

static ErlNifFunc nif_funcs[] = {
    {"socket", 1, sock_socket_nif},
    {"send", 1, sock_send_nif},
    {"loopback", 1, sock_loopback_nif},
    {"close", 1, sock_close_nif}
};

ERL_NIF_INIT(socket_nif, nif_funcs, NULL, NULL, NULL, NULL);

