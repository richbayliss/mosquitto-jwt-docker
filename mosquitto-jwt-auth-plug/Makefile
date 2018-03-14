include config.mk

NAME      = mosquitto_auth_plugin_jwt

MOSQUITTO = $(MOSQUITTO_SRC)
INC       = -I. -I$(MOSQUITTO)/lib -I$(MOSQUITTO)/src
CFLAGS    = -Wall -Werror -fPIC
#DEBUG     = -DMQAP_DEBUG

# LIBS      = -lcurl
LIBS      = -ljwt

all: $(NAME).so

$(NAME).so: $(NAME).o
	$(CC) $(CFLAGS) $(INC) -shared $^ -o $@ $(LIBS)

%.o : %.c
	$(CC) -c $(CFLAGS) $(DEBUG) $(INC) $< -o $@

clean:
	rm -f *.o *.so