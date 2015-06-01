class Ntfs3g < Formula
  desc "Read-write NTFS driver for FUSE"
  homepage "http://www.tuxera.com/community/ntfs-3g-download/"
  url "http://tuxera.com/opensource/ntfs-3g_ntfsprogs-2014.2.15.tgz"
  sha256 "4c3099400cb14b231a3c9d718b3a8d152d38555059341ce5fc6d02292a4a5b56"

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on :osxfuse

  def install
    # Workaround for hardcoded /sbin in ntfsprogs
    inreplace "ntfsprogs/Makefile.in", "/sbin", sbin

    ENV.append "LDFLAGS", "-lintl"
    args = ["--disable-debug",
            "--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--exec-prefix=#{prefix}",
            "--mandir=#{man}",
            "--with-fuse=external"]

    system "./configure", *args
    system "make"
    system "make", "install"

    # Install a script that can be used to enable automount
    File.open("#{sbin}/mount_ntfs", File::CREAT|File::TRUNC|File::RDWR, 0755) do |f|
      f.puts <<-EOS.undent
      #!/bin/bash

      VOLUME_NAME="${@:$#}"
      VOLUME_NAME=${VOLUME_NAME#/Volumes/}
      USER_ID=#{Process.uid}
      GROUP_ID=#{Process.gid}

      if [ `/usr/bin/stat -f %u /dev/console` -ne 0 ]; then
        USER_ID=`/usr/bin/stat -f %u /dev/console`
        GROUP_ID=`/usr/bin/stat -f %g /dev/console`
      fi

      #{opt_bin}/ntfs-3g \\
        -o volname="${VOLUME_NAME}" \\
        -o local \\
        -o negative_vncache \\
        -o auto_xattr \\
        -o auto_cache \\
        -o noatime \\
        -o windows_names \\
        -o user_xattr \\
        -o inherit \\
        -o uid=$USER_ID \\
        -o gid=$GROUP_ID \\
        -o allow_other \\
        "$@" >> /var/log/mount-ntfs-3g.log 2>&1

      exit $?;
      EOS
    end
  end
end