#include <common.h>

__kernel void depth_to_space(__read_only image2d_t input,
                             __private const int block_size,
                             __private const int input_height,
                             __private const int input_width,
                             __private const int input_depth_blocks,
                             __private const int output_height,
                             __private const int output_width,
                             __private const int output_depth_blocks,
                             __write_only image2d_t output) {
  const int out_d = get_global_id(0);
  const int out_w = get_global_id(1);
  const int out_h = get_global_id(2);

  if (out_d >= output_depth_blocks || out_h >= output_height || out_w >= output_width)
    return;

  const int out_pos = mad24(out_d, output_width, out_w);

  const int in_h = out_h / block_size;
  const int offset_h = out_h % block_size;
  const int in_w = out_w / block_size;
  const int offset_w = out_w % block_size;
  const int offset_d = (offset_h * block_size + offset_w) * output_depth_blocks;
  const int in_d = out_d + offset_d;

  if (in_h >= input_height || in_w >= input_width || in_d >= input_depth_blocks)
    return;

  const int in_pos = mad24(in_d, input_width, in_w);
  DATA_TYPE4 in_data = READ_IMAGET(input, SAMPLER, (int2)(in_pos, in_h));
  WRITE_IMAGET(output, (int2)(out_pos, out_h), in_data);
}

__kernel void space_to_depth(__read_only image2d_t input,
                             __private const int block_size,
                             __private const int input_height,
                             __private const int input_width,
                             __private const int input_depth_blocks,
                             __private const int output_height,
                             __private const int output_width,
                             __private const int output_depth_blocks,
                             __write_only image2d_t output) {
  const int d = get_global_id(0);
  const int w = get_global_id(1);
  const int h = get_global_id(2);

  if (h >= input_height || w >= input_width || d >= input_depth_blocks)
    return;

  const int in_pos = mad24(d, input_width, w);

  const int out_h = h / block_size;
  const int offset_h = h % block_size;
  const int out_w = w / block_size;
  const int offset_w = w % block_size;
  const int offset_d = (offset_h * block_size + offset_w) * input_depth_blocks;
  const int out_d = d + offset_d;

  if (out_d >= output_depth_blocks || out_h >= output_height || out_w >= output_width)
    return;

  const int out_pos = mad24(out_d, output_width, out_w);

  DATA_TYPE4 in_data = READ_IMAGET(input, SAMPLER, (int2)(in_pos, h));

  WRITE_IMAGET(output, (int2)(out_pos, out_h), in_data);
}
