void kernel_main(void)
{
    volatile char* video = (volatile char*)0xB8000;

    video[0] = 'T';
    video[1] = 0x0A;

    video[2] = 'O';
    video[3] = 0x0A;

    video[4] = 'S';
    video[5] = 0x0A;
    
    while (1)
    {
        // stay here forever 
    }
}

// void means this fn returns nothing 