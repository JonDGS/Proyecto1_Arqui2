# S-box for the SubBytes step
S_BOX = [
    [0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76],
    [0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0],
    [0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15],
    [0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75],
    [0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84],
    [0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf],
    [0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8],
    [0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2],
    [0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73],
    [0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb],
    [0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79],
    [0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08],
    [0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a],
    [0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e],
    [0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf],
    [0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16]
]

# Inverse S-box for the InvSubBytes step
INV_S_BOX = [
    [0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb],
    [0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb],
    [0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e],
    [0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25],
    [0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92],
    [0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84],
    [0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06],
    [0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b],
    [0x3a, 0x6e, 0x5a, 0x6d, 0x6f, 0x35, 0x83, 0x48, 0x95, 0xe3, 0x73, 0x66, 0x3c, 0x8e, 0x60, 0x7d],
    [0x4e, 0x54, 0x5b, 0xd0, 0x12, 0x7b, 0xb4, 0xd2, 0x5d, 0x7a, 0x2c, 0x3f, 0x27, 0x9c, 0x89, 0x8d],
    [0xc5, 0x15, 0x9f, 0x9e, 0xa6, 0x7c, 0x3d, 0x24, 0xa0, 0x93, 0x6b, 0x42, 0x4b, 0xd3, 0xd9, 0x64],
    [0x3f, 0x72, 0x63, 0x6e, 0x6b, 0x7b, 0x6d, 0x61, 0x77, 0x35, 0x7c, 0x60, 0x85, 0xe3, 0x9c, 0xd5],
    [0xd6, 0xd4, 0x4b, 0x2f, 0x6a, 0x6e, 0x68, 0x26, 0x22, 0xa4, 0x82, 0x33, 0x4d, 0x76, 0x21, 0x8c],
    [0xc6, 0x3a, 0x79, 0xd7, 0x8b, 0x61, 0x63, 0x24, 0x0c, 0x6a, 0x58, 0xd8, 0x4d, 0x3b, 0x55, 0x56],
    [0xa4, 0x59, 0x5e, 0xc1, 0x72, 0x2a, 0x57, 0x92, 0xa2, 0x6d, 0x6e, 0x74, 0x62, 0x0e, 0x80, 0x1b],
    [0xa6, 0x4f, 0x89, 0x43, 0x29, 0x8a, 0x39, 0x7e, 0x7b, 0x6a, 0x50, 0x2f, 0x99, 0x9b, 0xd4, 0xc7],
    [0xd9, 0x9e, 0xe1, 0x1a, 0x79, 0x61, 0xa3, 0x77, 0x5c, 0x64, 0x7b, 0x7c, 0x7b, 0x63, 0x2b, 0x52],
    [0xf1, 0x47, 0x3d, 0x5f, 0x4d, 0x95, 0x86, 0x61, 0x68, 0x90, 0xd1, 0x84, 0x9a, 0xa6, 0x4c, 0x83]
]

# Rcon values for key expansion
R_CON = [
    [0x01, 0x00, 0x00, 0x00],
    [0x02, 0x00, 0x00, 0x00],
    [0x04, 0x00, 0x00, 0x00],
    [0x08, 0x00, 0x00, 0x00],
    [0x10, 0x00, 0x00, 0x00],
    [0x20, 0x00, 0x00, 0x00],
    [0x40, 0x00, 0x00, 0x00],
    [0x80, 0x00, 0x00, 0x00],
    [0x1b, 0x00, 0x00, 0x00],
    [0x36, 0x00, 0x00, 0x00]
]

RGF_matrix = [
    [0x02, 0x01, 0x01, 0x03],
    [0x03, 0x02, 0x01, 0x01],
    [0x01, 0x03, 0x02, 0x01],
    [0x01, 0x01, 0x03, 0x02]
]

RGF_matrix_transpose = [
    [ 0x02, 0x03, 0x01, 0x01],
    [ 0x01, 0x02, 0x03, 0x01],
    [ 0x01, 0x01, 0x02, 0x03],
    [ 0x03, 0x01, 0x01, 0x02]
]

Inv_RGF_matrix = [
    [0xE, 0x09, 0xD, 0XB],
    [0xB, 0xE, 0x09, 0xD],
    [0xD, 0xB, 0xE, 0x09],
    [0x09, 0xD, 0xB, 0xE]
]

Inv_RGF_matrix_transpose = [
    [ 0xE, 0xB, 0xD, 0x09],
    [ 0x09, 0xE, 0xB, 0xD],
    [ 0xD, 0x09, 0xE, 0x0B],
    [ 0xB, 0xD, 0x09, 0xE]
]

key = [0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x09, 0xcf, 0x4f, 0x3c, 0x3e, 0xff]

text = [0x32, 0x43, 0xf6, 0xa8, 0x88, 0x5a, 0x30, 0x8d, 0x31, 0x31, 0x98, 0xa2, 0xe0, 0x37, 0x07, 0x34]

encryptedtext = [0x24, 0xb6, 0x76, 0x00, 0x72, 0xfe, 0x1e, 0x4b, 0x28, 0xbd, 0x4e, 0xf4, 0xbc, 0xc5, 0x7c, 0x63]