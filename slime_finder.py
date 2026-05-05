import ctypes
import math

# ================= CONFIGURATION =================
# Replace these with your actual data
SEED = -7335062620006416349  # Put your seed here
CURRENT_X = math.floor(10.0)              # Your X coordinate
CURRENT_Z = math.floor(100.0)             # Your Z coordinate
SEARCH_RADIUS = 5
# =================================================
def is_slime_chunk(seed, x, z):
    seed_long = ctypes.c_int64(seed).value
    x_int = ctypes.c_int32(x).value
    z_int = ctypes.c_int32(z).value

    combined_seed = (seed_long + 
                    (x_int * x_int * 0x4c1906) + 
                    (x_int * 0x5ac0db) + 
                    (z_int * z_int * 0x4307a7) + 
                    (z_int * 0x5f24f) ^ 0x3ad8025f)
    
    def java_next_int_10(s):
        s = (s ^ 0x5DEECE66D) & ((1 << 48) - 1)
        return ((s >> 17) % 10) == 0

    return java_next_int_10(combined_seed)

def main():
    center_x = CURRENT_X // 16
    center_z = CURRENT_Z // 16

    print(f"--- Beta 1.7.3 Slime Chunk Scanner ---")
    print(f"Seed: {SEED}")
    print(f"Center Location: Block({CURRENT_X}, {CURRENT_Z}) -> Chunk({center_x}, {center_z})")
    print(f"Search Radius: {SEARCH_RADIUS} chunks (approx {SEARCH_RADIUS * 16} blocks in all directions)\n")

    found_chunks = []

    # Scan the specified radius
    for z in range(center_z - SEARCH_RADIUS, center_z + SEARCH_RADIUS + 1):
        for x in range(center_x - SEARCH_RADIUS, center_x + SEARCH_RADIUS + 1):
            if is_slime_chunk(SEED, x, z):
                # Calculate distance from player's chunk (just for sorting)
                dist = max(abs(x - center_x), abs(z - center_z))
                found_chunks.append({"cx": x, "cz": z, "dist": dist})

    # Sort results so the closest chunks appear first
    found_chunks.sort(key=lambda c: c["dist"])

    print(f"Found {len(found_chunks)} slime chunks nearby:\n")

    if found_chunks:
        print(f"{'Chunk (X, Z)':<18} | {'Exact Block Boundaries'}")
        print("-" * 65)
        for chunk in found_chunks:
            cx = chunk["cx"]
            cz = chunk["cz"]
            
            # Calculate exact block coordinates
            block_x_start = cx * 16
            block_x_end = block_x_start + 15
            block_z_start = cz * 16
            block_z_end = block_z_start + 15
            
            chunk_str = f"({cx}, {cz})"
            block_str = f"X: [{block_x_start} to {block_x_end}]  Z: [{block_z_start} to {block_z_end}]"
            
            print(f"{chunk_str:<18} | {block_str}")
    else:
        print("No slime chunks found. Try increasing the SEARCH_RADIUS.")
        
    print("\nReminder: Dig out the area below Y=40 and stand at least 24 blocks away!")

if __name__ == "__main__":
    main()
