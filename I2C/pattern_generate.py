import random

PATNUM = 5
f = open("C:/myStudy/Topic Instance/I2C/pattern_gen.txt", "w")


def generate_data(PATTERN):
    devices = []
    data_addresses = []
    write_data = []
    
    for _ in range(PATNUM):
        device = '{:02x}'.format(random.randint(0, 127))        # device_addr
        data_address = '{:02x}'.format(random.randint(0, 255))  # data_addr
        data = '{:02x}'.format(random.randint(0, 255))          # write_data
        
        devices.append(device)
        data_addresses.append(data_address)
        write_data.append(data)
    
    return devices, data_addresses, write_data

# generate N group 
devices, data_addresses, write_data = generate_data(PATNUM)

f.write(str(PATNUM) + '\n\n\n')
for i in range(PATNUM):
    line = f"{devices[i]} {data_addresses[i]} {write_data[i]}\n\n"
    f.write(line)

