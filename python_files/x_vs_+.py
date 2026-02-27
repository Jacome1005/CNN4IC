import numpy as np

# =====================================
# funciones aux
# =====================================

def quantize_signed(W, bits):
    max_val = 2**(bits-1) - 1
    min_val = -2**(bits-1)
    return np.clip(W, min_val, max_val).astype(np.int8)

def quantize_unsigned(img, bits):
    max_val = 2**bits - 1
    return np.clip(img, 0, max_val).astype(np.uint8)

def conv2d_valid(img, kernel):
    H = img.shape[0]
    k = kernel.shape[0]
    out_size = H - k + 1
    out = np.zeros((out_size, out_size), dtype=np.int32)

    for i in range(out_size):
        for j in range(out_size):
            region = img[i:i+k, j:j+k]
            out[i, j] = np.sum(region * kernel)

    return out

def maxpool2x2(feature):
    H = feature.shape[0]
    pooled = np.zeros((H//2, H//2), dtype=np.int32)

    for i in range(0, H, 2):
        for j in range(0, H, 2):
            pooled[i//2, j//2] = np.max(feature[i:i+2, j:j+2])

    return pooled

# =====================================
# crear imags
# =====================================

def generate_plus(N):
    img = np.zeros((N,N), dtype=np.uint8)

    center = N//2 + np.random.randint(-1,2)
    thickness = np.random.randint(1,3)
    half_length = np.random.randint(N//3, N//2)
    intensity = np.random.randint(10,16)

    for dx in range(-half_length, half_length+1):
        for t in range(-thickness//2, thickness//2 + 1):
            x = center + t
            y = center + dx
            if 0 <= x < N and 0 <= y < N:
                img[x,y] = intensity

    for dy in range(-half_length, half_length+1):
        for t in range(-thickness//2, thickness//2 + 1):
            x = center + dy
            y = center + t
            if 0 <= x < N and 0 <= y < N:
                img[x,y] = intensity

    return img

def generate_x(N):
    img = np.zeros((N,N), dtype=np.uint8)

    center = N//2 + np.random.randint(-1,2)
    thickness = np.random.randint(1,3)
    half_length = np.random.randint(N//3, N//2)
    intensity = np.random.randint(10,16)
    slope_variation = np.random.choice([-1,0,1])

    for i in range(-half_length, half_length+1):
        for t in range(-thickness//2, thickness//2 + 1):

            x = center + i + t
            y = center + i + slope_variation
            if 0 <= x < N and 0 <= y < N:
                img[x,y] = intensity

            x = center + i + t
            y = center - i + slope_variation
            if 0 <= x < N and 0 <= y < N:
                img[x,y] = intensity

    return img

# =====================================
# kernels
# =====================================

def build_kernels(k):
    if k == 5:
        W_plus = np.array([
            [0, 0, 2, 0, 0],
            [0, 0, 2, 0, 0],
            [2, 2, 4, 2, 2],
            [0, 0, 2, 0, 0],
            [0, 0, 2, 0, 0]
        ])
        W_x = np.array([
            [2, 0, 0, 0, 2],
            [0, 2, 0, 2, 0],
            [0, 0, 4, 0, 0],
            [0, 2, 0, 2, 0],
            [2, 0, 0, 0, 2]
        ])
    elif k == 3:
        W_plus = np.array([
            [0, 2, 0],
            [2, 4, 2],
            [0, 2, 0]
        ])
        W_x = np.array([
            [2, 0, 2],
            [0, 4, 0],
            [2, 0, 2]
        ])
    else:
        raise ValueError("Kernel size no soportado")

    return W_plus, W_x

# =====================================
# clasificador (comparador)
# =====================================

def classify(img, W_plus, W_x):
    conv_plus = conv2d_valid(img, W_plus)
    pool_plus = maxpool2x2(conv_plus)
    score_plus = np.sum(pool_plus)

    conv_x = conv2d_valid(img, W_x)
    pool_x = maxpool2x2(conv_x)
    score_x = np.sum(pool_x)

    return 0 if score_plus > score_x else 1

# =====================================
# evaluacion
# =====================================

def evaluate_config(img_size, kernel_size, img_bits, weight_bits, samples=200):

    W_plus, W_x = build_kernels(kernel_size)
    W_plus = quantize_signed(W_plus, weight_bits)
    W_x = quantize_signed(W_x, weight_bits)

    correct = 0

    for _ in range(samples//2):
        img = generate_plus(img_size)
        img = quantize_unsigned(img, img_bits)
        if classify(img, W_plus, W_x) == 0:
            correct += 1

    for _ in range(samples//2):
        img = generate_x(img_size)
        img = quantize_unsigned(img, img_bits)
        if classify(img, W_plus, W_x) == 1:
            correct += 1

    return correct / samples

# =====================================
# MAIN
# =====================================

def main():

    configs = [
        (12,5,4,4),
        (12,5,3,3),
        (10,5,3,3),
        (10,3,4,4),
        (10,3,3,3),
        (8,3,3,3)
    ]

    for img_size, kernel_size, img_bits, weight_bits in configs:

        acc = evaluate_config(
            img_size,
            kernel_size,
            img_bits,
            weight_bits,
            samples=300
        )

        print(
            f"Image {img_size}x{img_size} | "
            f"Kernel {kernel_size}x{kernel_size} | "
            f"Img bits {img_bits} | "
            f"Weight bits {weight_bits} | "
            f"Accuracy: {acc:.3f}"
        )

if __name__ == "__main__":
    main()