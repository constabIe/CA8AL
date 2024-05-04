#include <stdio.h>
#include <stdint.h>
#include <limits.h>


int main (void) 
{
	// S = v_0 * t + ( a * t ^ 2 ) / 2
	// input: vx, vy, ax / 2, ay / 2, t

	int vx, vy, ax_half, ay_half, t;

	scanf("%d %d %d %d %d", &vx, &vy, &ax_half, &ay_half, &t);

	int S_x, S_y;

	S_x = t * (vx + ax_half * t);
	S_y = t * (vy + ay_half * t);

	printf("(S_x, S_y): (%d, %d)", S_x, S_y);

	return 0;
}
