
`define ROM_START 32'h00000000
`define ROM_SIZE  32'h00008000
`define ROM_MASK  (~(`ROM_SIZE-1))

`define RAM_START 32'h00020000
`define RAM_SIZE  32'h00010000
`define RAM_MASK  (~(`RAM_SIZE-1))

// Must be 4-bit aligned
`define EOC_START 32'h00080000
`define EOC_SIZE  32'h00000004
`define EOC_MASK  (~(`EOC_SIZE-1))

// Must be 4-bit aligned
`define GPO_START 32'h00080010
`define GPO_SIZE  32'h00000004
`define GPO_MASK  (~(`GPO_SIZE-1))

// Must be 4-bit aligned
`define PARO_START 32'h00080020
`define PARO_SIZE  32'h00000008
`define PARO_MASK  (~(`PARO_SIZE-1))

// Must be 4-bit aligned
`define LFSR_START 32'h00080030
`define LFSR_SIZE  32'h00000008
`define LFSR_MASK  (~(`LFSR_SIZE-1))

// Must be 4-bit aligned
`define CIPHER_START 32'h00080100
`define CIPHER_SIZE  32'h00000100
`define CIPHER_MASK  (~(`CIPHER_SIZE-1))
