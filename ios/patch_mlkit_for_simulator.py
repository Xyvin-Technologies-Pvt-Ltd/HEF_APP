#!/usr/bin/env python3
import os
import struct
import shutil

def patch_frameworks(pods_dir):
    frameworks = [
        'MLImage/Frameworks/MLImage.framework/MLImage',
        'MLKitCommon/Frameworks/MLKitCommon.framework/MLKitCommon',
        'MLKitVision/Frameworks/MLKitVision.framework/MLKitVision'
    ]

    for rel in frameworks:
        fw = os.path.join(pods_dir, rel)
        if not os.path.exists(fw) and not os.path.exists(fw + '.orig'):
            continue
        orig = fw + '.orig'
        if not os.path.exists(orig):
            shutil.copy2(fw, orig)
        
        sim = fw + '.sim'
        shutil.copy2(orig, sim)

        with open(sim, 'r+b') as f:
            data = bytearray(f.read())
            if len(data) < 4:
                continue
            magic = struct.unpack('>I', data[:4])[0]
            fat_slices = []
            if magic in (0xcafebabe, 0xbebafeca):
                nfat = struct.unpack('>I', data[4:8])[0]
                for i in range(nfat):
                    cputype, cpusub, offset, size, align = struct.unpack_from('>IIIII', data, 8 + i * 20)
                    if cputype == 0x0100000c:  # arm64
                        fat_slices.append((offset, size))
            else:
                fat_slices.append((0, len(data)))

            total_patched = 0
            for slice_off, slice_sz in fat_slices:
                pos = slice_off
                end = slice_off + slice_sz
                while pos + 32 < end:
                    m, cputype, cpusub, filetype, ncmds, sizeofcmds, flags, res = struct.unpack_from('<IIIIIIII', data, pos)
                    if m == 0xfeedfacf and cputype == 0x0100000c and 0 < ncmds < 100:
                        cmd_off = pos + 32
                        for _ in range(ncmds):
                            if cmd_off + 8 > end:
                                break
                            cmd, cmdsize = struct.unpack_from('<II', data, cmd_off)
                            if cmd == 0x32:  # LC_BUILD_VERSION
                                plat = struct.unpack_from('<I', data, cmd_off + 8)[0]
                                if plat == 2:  # PLATFORM_IOS -> PLATFORM_IOSSIMULATOR (7)
                                    struct.pack_into('<I', data, cmd_off + 8, 7)
                                    total_patched += 1
                            cmd_off += cmdsize
                        pos += 32
                    else:
                        pos += 4
            f.seek(0)
            f.write(data)
            print(f'[patch_mlkit] Generated {rel}.sim: {total_patched} objects updated to iOS Simulator')

if __name__ == '__main__':
    script_dir = os.path.dirname(os.path.abspath(__file__))
    pods_dir = os.path.join(script_dir, 'Pods')
    if os.path.exists(pods_dir):
        patch_frameworks(pods_dir)
