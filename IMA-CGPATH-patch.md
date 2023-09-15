# Ref:
```
https://patchwork.kernel.org/project/linux-integrity/patch/20221224160912.17830-1-enrico.bravi@polito.it/
https://patchwork.kernel.org/project/linux-integrity/patch/20221224162830.21554-1-enrico.bravi@polito.it/
```

# Build the Kernel for the first time
```
git clone https://github.com/intel/tdx-tools.git
cd tdx-tools/build/ubuntu-22.04/intel-mvp-tdx-kernel/
sh build.sh
```

# Patch and build the kernel again
patch MVP kernel at mvp-tdx-kernel-v5.19.17/security/integrity/ima/ according to the code patch in above reference link

patch build.sh to not pull and manipulate kernel source code:
```
diff --git a/build/ubuntu-22.04/intel-mvp-tdx-kernel/build.sh b/build/ubuntu-22.04/intel-mvp-tdx-kernel/build.sh
index 846d0c2..f0bf18f 100755
--- a/build/ubuntu-22.04/intel-mvp-tdx-kernel/build.sh
+++ b/build/ubuntu-22.04/intel-mvp-tdx-kernel/build.sh
@@ -54,7 +54,7 @@ build() {
 }

 pushd "${CURR_DIR}"
-get_source
-prepare
+#get_source
+#prepare
 build
 popd
```

rebuild the kernel:
```
sh build.sh
```
during build process, need to config kernel build option for IMA as bellow:
```
Integrity subsystem (INTEGRITY) [Y/n/?] y
  Digital signature verification using multiple keyrings (INTEGRITY_SIGNATURE) [Y/n/?] y
    Enable asymmetric keys support (INTEGRITY_ASYMMETRIC_KEYS) [Y/n/?] y
      Require all keys on the integrity keyrings be signed (INTEGRITY_TRUSTED_KEYRING) [Y/?] y
      Provide keyring for platform/firmware trusted keys (INTEGRITY_PLATFORM_KEYRING) [Y/n/?] y
      Provide a keyring to which Machine Owner Keys may be added (INTEGRITY_MACHINE_KEYRING) [N/y/?] n
  Enables integrity auditing support  (INTEGRITY_AUDIT) [Y/?] y
  Integrity Measurement Architecture(IMA) (IMA) [Y/n/?] y
    Default template
    > 1. ima-ng (default) (IMA_NG_TEMPLATE)
      2. ima-sig (IMA_SIG_TEMPLATE)
      3. ima-dep-cgn (IMA_DEP_CGN_TEMPLATE) (NEW)
      4. ima-cgpath (IMA_CGPATH_TEMPLATE) (NEW)
    choice[1-4?]: 4
    Default integrity hash algorithm
    > 1. SHA1 (default) (IMA_DEFAULT_HASH_SHA1)
      2. SHA256 (IMA_DEFAULT_HASH_SHA256)
      3. SHA512 (IMA_DEFAULT_HASH_SHA512)
    choice[1-3?]: 1
    Enable multiple writes to the IMA policy (IMA_WRITE_POLICY) [N/y/?] n
    Enable reading back the current IMA policy (IMA_READ_POLICY) [N/y/?] n
    Appraise integrity measurements (IMA_APPRAISE) [Y/n/?] y
    Enable loading an IMA architecture specific policy (IMA_ARCH_POLICY) [N/y/?] n
  IMA build time configured policy rules (IMA_APPRAISE_BUILD_POLICY) [N/y/?] n
  ima_appraise boot parameter (IMA_APPRAISE_BOOTPARAM) [Y/n/?] y
  Support module-style signatures for appraisal (IMA_APPRAISE_MODSIG) [Y/n/?] y
  Require all keys on the .ima keyring be signed (deprecated) (IMA_TRUSTED_KEYRING) [Y/n/?] y
  Permit keys validly signed by a built-in or secondary CA cert (EXPERIMENTAL) (IMA_KEYRINGS_PERMIT_SIGNED_BY_BUILTIN_OR_SECONDARY) [N/y/?] n
  Create IMA machine owner blacklist keyrings (EXPERIMENTAL) (IMA_BLACKLIST_KEYRING) [N/y/?] n
  Load X509 certificate onto the '.ima' trusted keyring (IMA_LOAD_X509) [N/y/?] n
  Disable htable to allow measurement of duplicate records (IMA_DISABLE_HTABLE) [N/y/?] n
  EVM support (EVM) [Y/n/?] y
    FSUUID (version 2) (EVM_ATTR_FSUUID) [Y/n/?] y
    Additional SMACK xattrs (EVM_EXTRA_SMACK_XATTRS) [Y/n/?] y
    Add additional EVM extended attributes at runtime (EVM_ADD_XATTRS) [Y/n/?] y
    Load an X509 certificate onto the '.evm' trusted keyring (EVM_LOAD_X509) [N/y/?] n
First legacy 'major LSM' to be initialized
  1. SELinux (DEFAULT_SECURITY_SELINUX)
  2. Simplified Mandatory Access Control (DEFAULT_SECURITY_SMACK)
  3. TOMOYO (DEFAULT_SECURITY_TOMOYO)
> 4. AppArmor (DEFAULT_SECURITY_APPARMOR)
  5. Unix Discretionary Access Controls (DEFAULT_SECURITY_DAC)
choice[1-5?]: 4
```

the results:
```
chr@css-sprqct-prc8:~/cc-poc/tdx-tools/build/ubuntu-22.04/intel-mvp-tdx-kernel$ ls -l
total 160688
-rwxr-xr-x  1 chr chr     1680  9月 14 11:04 build.sh
drwxr-xr-x 16 chr chr     4096  9月  7 13:42 debian
drwxr-xr-x  8 chr chr     4096  9月  7 13:42 debian.master
drwxr-xr-x  5 chr chr     4096  9月  7 13:42 linux-5.19.17
-rw-r--r--  1 chr chr  7209462  9月 14 11:28 linux_5.19.17-mvp29v4+4.tdx_amd64.build
-rw-r--r--  1 chr chr    22519  9月 14 11:28 linux_5.19.17-mvp29v4+4.tdx_amd64.buildinfo
-rw-r--r--  1 chr chr     9001  9月 14 11:28 linux_5.19.17-mvp29v4+4.tdx_amd64.changes
-rw-r--r--  1 chr chr 11689357  9月 14 11:28 linux_5.19.17-mvp29v4+4.tdx_amd64.tar.gz
-rw-r--r--  1 chr chr   712278  9月 14 11:28 linux-buildinfo-5.19.17-mvp29v4+4-generic_5.19.17-mvp29v4+4.tdx_amd64.deb
-rw-r--r--  1 chr chr   306112  9月 14 11:24 linux-cloud-tools-5.19.17-mvp29v4+4_5.19.17-mvp29v4+4.tdx_amd64.deb
-rw-r--r--  1 chr chr   286902  9月 14 11:28 linux-cloud-tools-5.19.17-mvp29v4+4-generic_5.19.17-mvp29v4+4.tdx_amd64.deb
-rw-r--r--  1 chr chr   294912  9月 14 11:23 linux-cloud-tools-common_5.19.17-mvp29v4+4.tdx_all.deb
-rw-r--r--  1 chr chr 11913632  9月 14 11:23 linux-doc_5.19.17-mvp29v4+4.tdx_all.deb
-rw-r--r--  1 chr chr 15396912  9月 14 11:24 linux-headers-5.19.17-mvp29v4+4_5.19.17-mvp29v4+4.tdx_all.deb
-rw-r--r--  1 chr chr  3544066  9月 14 11:28 linux-headers-5.19.17-mvp29v4+4-generic_5.19.17-mvp29v4+4.tdx_amd64.deb
-rw-r--r--  1 chr chr 12206272  9月 14 11:24 linux-image-unsigned-5.19.17-mvp29v4+4-generic_5.19.17-mvp29v4+4.tdx_amd64.deb
-rw-r--r--  1 chr chr  1580954  9月 14 11:28 linux-libc-dev_5.19.17-mvp29v4+4.tdx_amd64.deb
-rw-r--r--  1 chr chr 23036182  9月 14 11:25 linux-modules-5.19.17-mvp29v4+4-generic_5.19.17-mvp29v4+4.tdx_amd64.deb
-rw-r--r--  1 chr chr 66223392  9月 14 11:28 linux-modules-extra-5.19.17-mvp29v4+4-generic_5.19.17-mvp29v4+4.tdx_amd64.deb
-rw-r--r--  1 chr chr   287028  9月 14 11:23 linux-source-5.19.17_5.19.17-mvp29v4+4.tdx_all.deb
-rw-r--r--  1 chr chr  8650950  9月 14 11:24 linux-tools-5.19.17-mvp29v4+4_5.19.17-mvp29v4+4.tdx_amd64.deb
-rw-r--r--  1 chr chr   287040  9月 14 11:28 linux-tools-5.19.17-mvp29v4+4-generic_5.19.17-mvp29v4+4.tdx_amd64.deb
-rw-r--r--  1 chr chr   514002  9月 14 11:23 linux-tools-common_5.19.17-mvp29v4+4.tdx_all.deb
-rw-r--r--  1 chr chr   304852  9月 14 11:23 linux-tools-host_5.19.17-mvp29v4+4.tdx_all.deb
drwxr-xr-x 31 chr chr     4096  9月 14 11:05 mvp-tdx-kernel-v5.19.17
```

# Install new kernel with ima-cgpath enabled
put following deb files to a running TDVM:
```
ls -l deb/
-rw-r--r-- 1 tdx tdx  3544066 Sep 14 06:52 linux-headers-5.19.17-mvp29v4+4-generic_5.19.17-mvp29v4+4.tdx_amd64.deb
-rw-r--r-- 1 tdx tdx 15396912 Sep 14 06:52 linux-headers-5.19.17-mvp29v4+4_5.19.17-mvp29v4+4.tdx_all.deb
-rw-r--r-- 1 tdx tdx 12206272 Sep 14 06:53 linux-image-unsigned-5.19.17-mvp29v4+4-generic_5.19.17-mvp29v4+4.tdx_amd64.deb
-rw-r--r-- 1 tdx tdx 23036182 Sep 14 06:53 linux-modules-5.19.17-mvp29v4+4-generic_5.19.17-mvp29v4+4.tdx_amd64.deb
-rw-r--r-- 1 tdx tdx 66223392 Sep 14 06:53 linux-modules-extra-5.19.17-mvp29v4+4-generic_5.19.17-mvp29v4+4.tdx_amd64.deb
```

Install the kernel:
```
dpkg -i *.deb
```

# enable IMA
edit file /etc/default/grub to add:
```
GRUB_CMDLINE_LINUX="ima_policy=tcb"
```

and update grub:
```
update-grub
```

# reboot, build Kubernetes cluster and deploy Nginx in node
the IMA measurement result samples as bellow:
```
root@tdx-ima-node1:~# grep 92607f04_f4be_427f_8356_bde95aacc334 /sys/kernel/security/ima/ascii_runtime_measurements
10 204b274f178f3154f14baa9665f0795211e6c396 ima-cgpath runc:/usr/local/sbin/runc:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-b1d11ef0c2fd8b2262e8613f1b9cdcff254ab2e261896d413606de37e4163bf6.scope sha1:da39a3ee5e6b4b0d3255bfef95601890afd80709 /run/containerd/io.containerd.runtime.v2.task/k8s.io/b1d11ef0c2fd8b2262e8613f1b9cdcff254ab2e261896d413606de37e4163bf6/rootfs/etc/resolv.conf
10 d66e21530e1bd8efd578a1b6a74e43f5fd425f89 ima-cgpath runc:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-b1d11ef0c2fd8b2262e8613f1b9cdcff254ab2e261896d413606de37e4163bf6.scope sha1:7a7aa50808d98f3fc559e6e65d16daa5c8b68a0c /pause
10 16612c379b95072123f740d5e34e028ad8fa8cd6 ima-cgpath runc:/usr/local/sbin/runc:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:da39a3ee5e6b4b0d3255bfef95601890afd80709 /run/containerd/io.containerd.runtime.v2.task/k8s.io/4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535/rootfs/etc/hosts
10 bae6ad8214681167868fd3708e483f1c227094d8 ima-cgpath runc:/usr/local/sbin/runc:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:b2c2280acf9c30d23cf9b9eb460115a5b56bf983 /etc/passwd
10 fdd5a0770d96831894a41aec6db9fe69dc99810e ima-cgpath runc:/usr/local/sbin/runc:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:715ba5c345df05fa28f0bed54f5960159536c99a /etc/group
10 68d9a6eded745c748945ab7c1a2c0b34ee9fd9e5 ima-cgpath runc:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:befa5b68f0570c67437ceae44abc737f2267145d /usr/sbin/nginx
10 05d0ff1e64208bf1d4a88bb004d70f07ca8aa4e8 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:ac1031db6e0a04226d6300f361e2702a03edf19d /lib/x86_64-linux-gnu/ld-2.24.so
10 3557ecfd863a1dfe8b25af8abff9378cd4bbd83b ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:e824ddd5068f94b0d76fa8bdbbb7bd92f16d0c22 /etc/ld.so.cache
10 29cc08070bff89a49e082f09627760333e46cad4 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:01db9447c2b07a559381f77eb523e4903ebf6ead /lib/x86_64-linux-gnu/libdl-2.24.so
10 7ff6e13f816b14269239a726b2d0a148cab2c5ec ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:a8040ed59dea41f4abe9ff0c1f74d8f460e5e4e0 /lib/x86_64-linux-gnu/libpthread-2.24.so
10 68e1023c675f2ef953cb9deeb4af16792721a898 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:d00443619360a7980b6048e49b753b01857e8bc3 /lib/x86_64-linux-gnu/libcrypt-2.24.so
10 5c182675fc844a69fdaa8886ea8454ad08712db9 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:c03addc3a7fe96cef59f570ac4acf95714442c14 /lib/x86_64-linux-gnu/libpcre.so.3.13.3
10 8eea6c0d85e1fb14ba6e1e6273c481be8e783f04 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:a69945857c6de7ad97759d2bbcf983c4a2ff12b7 /usr/lib/x86_64-linux-gnu/libssl.so.1.1
10 d7b4c98d6cf6d986a924769810124f9fc0c6e292 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:9e446adbb2e35d4eebcc11fe6c5461a9ccdd5d62 /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1
10 b091331465514b560db4e87c58720e7886a29457 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:0e52c5955d1b3ebc12c6e81f48e26dac9f34597a /lib/x86_64-linux-gnu/libz.so.1.2.8
10 92e58fb1ad3a2e8e644cc963e04c3e2606bb82ee ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:81a6361b56ed07f58021f6a4795a58d565253956 /lib/x86_64-linux-gnu/libc-2.24.so
10 c4f020de8be5878ee0f734c6b51a5eb2f46c1096 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:d7948ef155843e0c7d055bdc3632877b49873864 /usr/share/zoneinfo/UTC
10 5e4ad7e88a3794da57c665761042d1baeb14b787 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:edaf7e49bf5c8d8255d010fe11b9184fa76e660c /etc/nginx/nginx.conf
10 c2c338cd3ce31c55ac90d0ee11de1f6dfad767a4 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:340e00144bd53d4227d9a90d5e37c8ac4370158a /etc/nsswitch.conf
10 779810fe4e456ab6b3c562ef924752716ec336b7 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:d443956735e554b8896feb4d9976b780c0cd6556 /lib/x86_64-linux-gnu/libnss_compat-2.24.so
10 86b7e7745f7113ba3fc3fe0dde2bdc183802b349 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:a36a01330e45aa4bdcbfa85bf3c8107f88b6177f /lib/x86_64-linux-gnu/libnsl-2.24.so
10 990f2ea8b707d4e526ff8e80ee6b796ef87f8b23 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:58c79a6a4b94ac41981b0827692c295e5bf9f813 /lib/x86_64-linux-gnu/libnss_nis-2.24.so
10 d5dae1689245ebab7be3f6b88f0d1cbee8973e72 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:9e5a75d15df46d76a3d7653f2a24d7af48ba946f /lib/x86_64-linux-gnu/libnss_files-2.24.so
10 8042313b81b94ca07242044c84ad21ca32c10f81 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:ccb8f78d8a3eaea874ff390f53c05697208a38ed /etc/nginx/mime.types
10 b69289d51e6bf947180889a2e10a9d2d5ba5d426 ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:8d4bded2dabb978793b3a8005001d702804303fb /etc/nginx/conf.d/default.conf
10 259d8db19aab26951596c9e39860fe4a0306021d ima-cgpath /usr/sbin/nginx:/usr/local/bin/containerd-shim-runc-v2:/usr/lib/systemd/systemd:swapper/0 /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod92607f04_f4be_427f_8356_bde95aacc334.slice/cri-containerd-4d22165929ba86eb436d8f8ad3dc997f47ed3030b5f17346ceccc6b863017535.scope sha1:da39a3ee5e6b4b0d3255bfef95601890afd80709 /run/nginx.pid
```