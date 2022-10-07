
#ifndef BRACELET_H
#define BRACELET_H

//payload of the pairing msg
typedef nx_struct pair_msg {
	nx_uint8_t type;
	nx_uint8_t key[20];
} pair_msg_t;


//payload of the position msg
typedef nx_struct pos_msg {
	nx_uint8_t type;
	nx_uint8_t status;
	nx_uint8_t x_pos;
	nx_uint8_t y_pos;

} pos_msg_t;


#define KEY_MSG 0
#define PAIR_ACK 1
#define INFO 2
#define FALL 3
#define MISSING 4

enum{
	AM_MSG = 6,
};

// Pre-loaded random keys
#define FOREACH_KEY(KEY) \
		KEY(NQwyRCbM2wDXm9BqqGfC) \
		KEY(x4RHomUiPSelX7VIH2nL) \
		KEY(4CIT8XXlehn1wcQa6NdE) \
		KEY(XRZkQHhYBQNuiIANXhNm) \
		KEY(5a4gopBEdhRgB9Bl5I5f) \
		KEY(GYeN1n0viZlHGviMeaKE) \
		KEY(iZJHEOv8sCnMhz3NPjjW) \
		KEY(eGTVc0c45fN2ZAKt7QG1) \
		KEY(4eU0qQoaX8bdLOw6PMfQ) \
		
        
#define GENERATE_ENUM(ENUM) ENUM,
#define GENERATE_STRING(STRING) #STRING,
enum KEY_ENUM {
    FOREACH_KEY(GENERATE_ENUM)
};
static const char *RANDOM_KEY[] = {
    FOREACH_KEY(GENERATE_STRING)
};
       

#endif
