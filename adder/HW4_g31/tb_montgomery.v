`timescale 1ns / 1ps
//`include "montgomery.v"

module tb_montgomery();

    reg clk;
    reg resetn;
    reg start;
    reg [1023:0] in_a;
    reg [1023:0] in_b;
    reg [1023:0] in_m;
    wire [1024:0] result;
    reg [1024:0] expected_results;
    wire done;

    wire correct;
    assign correct = (result == expected_results);

    // Instantiate the montgomery module
    montgomery uut (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .in_a(in_a),
        .in_b(in_b),
        .in_m(in_m),
        .result(result),
        .done(done)
    );

    // Generate clock signal
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Apply reset and input stimulus
    initial begin
        // Initialize signals
        resetn = 0;
        start = 0;
        in_a = 1024'd0;
        in_b = 1024'd0;
        in_m = 1024'd0;

        // Dump waveform data
        $dumpfile("tb_montgomery.vcd");
        $dumpvars(1, tb_montgomery);
        $dumpvars(1, uut);
        //$dumpvars(1, uut.shiftMB);
        //$dumpvars(1, uut.shiftMB.adder);
        $dumpvars(1, uut.multi);
        $dumpvars(1, uut.shiftA);
        $dumpvars(1, uut.adder);
        //$dumpvars(1, uut.shifter);

        // Apply reset
        #10 resetn = 1;  // Release reset after 10ns

        $display("Test 4");
        in_a = 1024'ha958eb1ec7084cf83d25941ba30b0aadaad986839a3a8e3028503037e875bce4637cdd321ca3ffe3c39adb4dfbbc230d4c2237acc33f636f2b9f4edb9d9401a9c2b2a90f26c56cefe22d49eefd468bbcb82a645835a537a9b80c3b9a8b16e6f271eece2712b9d229dc7534b9512c9fe0ee4ec5642dcb0c51c75d6baa6b219b97;
        in_b = 1024'h9cabe30bb78713ae0cff2f816a4fb7ca0633e5598cf4f6b2274bfa55522d4130ce5c7c664427aa56bb471ad1727d11dfa83162695e19fd434025a7893d04cceab19910ab60c1691dd2a5fb4f45ad6f685e98eca311cc388bb197e52df9b17776e84ef3121a773482cdc3dbfc548396abf3bf3dd70f217e4da5bda2e4eb76b197;
        in_m = 1024'he14accdd8d4576ec8485f5589055b1caca2ebf09486d8f1e7870695a5fd3754b497c7c7f85fd2c2494df65f34e8be4b6ce67ea5e430793519f94c1c64abff479ad99cea14fa1f042f6a3d1b73d549e1da1c62f7854d012c5065953008e8a32c34191f144894c87c4ed6869cd5368df5fca97a90eae185bada3244e021c3791d3;
        expected_results = 1024'h5fe41344df3a66725bc321f63cb1f5cc7dfc6bb391d82e7a18371f07638547798426b00ffba9c07c6e526fab23fba97d2c9d10a74300492e31674f7e887af3a41a77389f7ebbc5e174805e95fd03c973423f45a2302b25cdf219cb15348b9dda69a99e7e8d08638581b4f0701f6a0c2f0710d9d7664f772c4c207974e2e608e8;
        #10 start = 1;  // Start computation
        #10 start = 0;  // Deassert start signal after one clock cycle
        wait(done == 1) // 1 billion time units at a 1ns timescale
        $display("Diff: %h", expected_results - result);
        resetn = 0;
        #20 resetn = 1;  // Release reset after 10ns  // Release reset after 10ns

        

        //$finish;

        // Test case 1: Basic input values
        $display("Test 1");
        in_a = 1024'h2394a8c9e2c6abc0edb8734fb607d38620559f7220a7a45b60a298241a9888760f0aede90b9467975a6cf461e75242d6871a24d024f15ca6ab969a1617a5432363b4792838172caf1dec516490c43b22d592c9f84294af8bfe9ccd0e09cd5a683c84feec717eb638c74228f1393f8ebcf634845a3b1c51f893c2286ef76f49b1;
        in_b = 1024'h33c211b567e0c0ce6610393b49e77a5fb33183f2ef3bd0c34e15369f3537c592b927242339b723be6c59d907c2cbef8d6afee9803ed39bc4fe2f7773546ed91771322659fdd65ad3402f62be5f34bbdf7ca9aa874d678a9decb13abe8b9c3badbdb709dfee20ec628be2748831cac28e1e027e33eeb69ff23499dc429d74a517;
        in_m = 1024'h83a6c5c93235f2f4905daaa92deddb7235d196d00c713a582030a113495b64c40d579c795c171370251a7651affcd685caeee9b4b7c1f7ed3c805f565c2ac5ed7e83e68b34ffba6bdeeb98894c6a406a4e6a2ea9d45e0285d4ad9250e6108b07150d513e834ae1d93ba570636737aaedf95d829f9bdb8ceeb0fefd5e1d47ef05;
        expected_results = 1024'h200c28fdb80e80addadb9c9371c523a8b9e22e324e2fc873895987577d6d0fabc8d874f2bbd21b07ea86058deb5732ad0c432e71ca752a7e0496e83215de9044ebc739a929a144e127325d63e7826201d17f26bc1dc8cf711796e8ea8ff2f306f96558ab88e696457cf2a15b85b3c7534b3136f48a3b05a037776ece854173bf;
        #10 start = 1;  // Start computation
        #10 start = 0;  // Deassert start signal after one clock cycle

        // Wait for computation to complete
        //wait(done);
        wait(done == 1) // 1 billion time units at a 1ns timescale
        // Display results
        $display("Diff: %h", expected_results - result);
        resetn = 0;
        #20 resetn = 1;  // Release reset after 10ns



        $display("Test 2");
        in_a = 1024'he47c3cc1944a0f56b9b6a84ed643221ba8fd33b447746f3d142c5dac1ece86984180efcddeb2e2f6b5712742cc0cba90b9c3dee8ebd49a1fb20c3a12b8aed0c93e077936a177a29af5d97d0406e029a0c8190a88d9c59fd28e932c8f502af843c8cb9d28f29436e9d3e255fe6a5d6e7054c55698660e04373b8c002fbbe7b046;
        in_b = 1024'ha43736d213b9148ce75ee249c012cf2c052962f322f1be636c7faed922b23e4bd338c07662dbfd0bd6240f463accec6ef21ff466cc29c05a93c9bd177d6f9dc4da2ca2f3da7b66359cbe6b84cabec8ec2c09bd80b5616a6930f45bb2706c98001a813a1acff4c673a728c203b3a2bd8d68188e9e7c2bf822d31a13b784cdd7ef;
        in_m = 1024'hef059fff1ffeebaaf4027030afc37e35794da72fa064675aa975b53e647e3b02e6e793c8f8413ec9a994180db86227338828ba9fff6ec9dc1b00f74da80647cfb319d35ae277b903278155476ada0ea1cf8d07caee5e7ad727b2067c97a59f6070168052a3a4335daeda44642d34937001331fe2766a337b4aafacdceeb7e5b7;
        expected_results = 1024'hd0904e20fb8fcdf388840a218c4edfd8a9d101e5084ed1cda137ac242785b8c4119dc93c79ea548914f4334f15688a71346f56c5a45bf4cf2a95cf680d3d99999263ccefc07c05ececf3a24a49282306f2f8a2456011d2c7df1a0ca836739d9f7baf30aeef622856ac1f279d5c9548fccbb511a906675bc895e32712dc6bf815;
        #10 start = 1;  // Start computation
        #10 start = 0;  // Deassert start signal after one clock cycle
        wait(done == 1) // 1 billion time units at a 1ns timescale
        $display("Diff: %h", expected_results - result);
        resetn = 0;
        #20 resetn = 1;  // Release reset after 10ns

        $display("Test 3");
        in_a = 1024'he47c3cc1944a0f56b9b6a84ed643221ba8fd33b447746f3d142c5dac1ece86984180efcddeb2e2f6b5712742cc0cba90b9c3dee8ebd49a1fb20c3a12b8aed0c93e077936a177a29af5d97d0406e029a0c8190a88d9c59fd28e932c8f502af843c8cb9d28f29436e9d3e255fe6a5d6e7054c55698660e04373b8c002fbbe7b046;
        in_b = 1024'ha43736d213b9148ce75ee249c012cf2c052962f322f1be636c7faed922b23e4bd338c07662dbfd0bd6240f463accec6ef21ff466cc29c05a93c9bd177d6f9dc4da2ca2f3da7b66359cbe6b84cabec8ec2c09bd80b5616a6930f45bb2706c98001a813a1acff4c673a728c203b3a2bd8d68188e9e7c2bf822d31a13b784cdd7ef;
        in_m = 1024'hef059fff1ffeebaaf4027030afc37e35794da72fa064675aa975b53e647e3b02e6e793c8f8413ec9a994180db86227338828ba9fff6ec9dc1b00f74da80647cfb319d35ae277b903278155476ada0ea1cf8d07caee5e7ad727b2067c97a59f6070168052a3a4335daeda44642d34937001331fe2766a337b4aafacdceeb7e5b7;
        expected_results = 1024'hd0904e20fb8fcdf388840a218c4edfd8a9d101e5084ed1cda137ac242785b8c4119dc93c79ea548914f4334f15688a71346f56c5a45bf4cf2a95cf680d3d99999263ccefc07c05ececf3a24a49282306f2f8a2456011d2c7df1a0ca836739d9f7baf30aeef622856ac1f279d5c9548fccbb511a906675bc895e32712dc6bf815;
        #10 start = 1;  // Start computation
        #10 start = 0;  // Deassert start signal after one clock cycle
        wait(done == 1) // 1 billion time units at a 1ns timescale
        $display("Diff: %h", expected_results - result);
        resetn = 0;
        #20 resetn = 1;  // Release reset after 10ns



        $display("Test 5");
        in_a = 1024'ha9bd55ef3e1de5ddac91e9c232cc7e150736c0169b92de61066fb1949e4a0a02b53704ad5416a3df9fa37f0bb1677da5419c30d88382665a6b8522ea3b3e9cf4dbea626ea00b9059845ec494b2cafcd4dfc5ee4af54a602b7ba35dd42e02887a5981f26fd1ba61fbfa7d7a889bcc62b8d84da15e2ccdb9dcf9b47aa3eed98000;
        in_b = 1024'hb275e62cc793611ae2d6b2394deeca08165f98f5d74e7346ed67c6c7156c660b4a51da11ff543d0ee0367262b77f3164cf4b6ad7951f74a66fa1a227f0b132c794018719752e18dbf049122d38aacfa2bf76f51546b81236e60860dfbe431411bdbdaf6ae16e54a28dd933d9a73af4bdf3cfbe29ace7732e5c3cc88e33e06e3;
        in_m = 1024'hcc30404c513f6c9c781316a067c0e9120d98019310ad3c9e2644aee1e2c61afb15690276cc8713107ebd30dc305a5737242312ddcb15e0389dfafa94fba0d6776051cc0f56a574fb13986834395b29b4b7ab3cf0b9ec13c820e2f5785333f922082401b450dc6aadec19c7eeff9ecb9ba31baffa2063447125c4ece276f1594f;
        expected_results = 1024'ha9de88e06f0528b977030842e13afd52ff1029d7d0c84758390243986c200ee40c2a65842fb9e8a7d918a533cfae467f707509feabae53e499478ebbbc9fb32c94b9c88569e897c425c7fd3f2948177debb18708111d13b4ac8a31d0f754d833ca12719bd57b83a5543169f17fc9b2d4c67d87932e52265586d8a7926948e4ed;
        #10 start = 1;  // Start computation
        #10 start = 0;  // Deassert start signal after one clock cycle
        wait(done == 1) // 1 billion time units at a 1ns timescale
        $display("Diff: %h", expected_results - result);
                resetn = 0;
        #20 resetn = 1;  // Release reset after 10ns  // Release reset after 10ns

        $display("Test 6");
        in_a = 1024'h29bddb845786e1255db8f13c9873ffb817f06d73fb64ad33dd5f848feebf8b13d9af164a053ed312d64928bb2da93f8f90db7fd304a36bd1b56d1edbfa6886bcb6ab024e74968a2dbe14fd9db835a567b58f444f6324c6444c2b0264d285b020f3e645201a26c9ceed7c6edcafb9bea89ce1eb03ff5048f484e4ff5a6412a5d0;
        in_b = 1024'h9124e1ee4f41f19c4e3cfec05996d91efdb8d500a02ff9ca5f58073e5646ea558dbf5c0c1f7900586a45d36446a22723a45cda8f3b9415931548eb6accb9aebc54531411997e83341db32e50c222736c2fdc5f9f6698cbdd243c34f4b05ee1fd0b74ff13cd2d808c35d53d7a752d89841ec4492a04a8ceb48cb5c63821957a01;
        in_m = 1024'ha93151f196872a366305e4529211554b1524af50641d946506f454d2436276042d394f55221e31609bd163f483a655857efa146a150d63600f9d607ea4b59f1b1911ada1d0056ef75dfdd42efa1c6262d95f35f54e471ed70e364c485832135e28213e5fe74e1b6169a368e53baa06f3f81a841f42a6929f27a22a10fa6112e5;
        expected_results = 1024'h6dc99e0981eebdd932994c280fef8b324580cd733fc17f346334299198b14c63477067c80101f3b2f0b1cb32d685b67a68bd7059cb9f0c040cc2ca26ad3585bc7e3a1dd6c4cfae73caee2e0a4dcc86baa9862a788d7d99325bd6eb8c54ab598a33bfaccf30bda5f6102eeb82e2bc05fb7b10d2e01924974b5f259f18552f7200;
        #10 start = 1;  // Start computation
        #10 start = 0;  // Deassert start signal after one clock cycle
        wait(done == 1) // 1 billion time units at a 1ns timescale
        $display("Diff: %h", expected_results - result);
                resetn = 0;
        #20 resetn = 1;  // Release reset after 10ns  // Release reset after 10ns

        $display("Test 7");
        in_a = 1024'h8c989614da4ac9e35a0a330594383608106d188657160c4422f5444102943e6c013b4f801835b555da98e514b22b245ef7714eede12f5775ca454d48df3d355596785cfc1852ee95b36638e2904516268229df01cd8290d82659eca40256481c542e3349962bd6318cc39b42e87194411908d27a4697a564439fec5f7a052ce6;
        in_b = 1024'hef972af530ac9871fc4e9e4b3f6762ca44a2ca585c6c0193cfe098839e5ed027d3ccbb68c1a19de87fca5691f8f053a24ef6f5708d94743b43cb7224c46f5a35ac88e51204fa428090177e9d5ded58658ac55dd355fbf7feb163c77c2a6fe50d67a7b4b421cf8b8c0ac10df8f8bdcf9201925227412e7a719694f294b86dea1;
        in_m = 1024'ha55adbfc1faba405053000c46f3950d2a38d149e456fef0bc50d0a21c2ab84b69bb8dfca8d9fc9407ec016ed7da61dddc85850d31da5ec7c842d09fef398544138e3a071c64e8be67797e8018418ef064a7a12cfcb78066c1fec7a4d1ce5dad95e5bfbc20b6425c9304d25e1678533073641d3fb57fdcf4c6a8f9b34efe15f27;
        expected_results = 1024'h404512d6b9a83c48c506487d4430bf20e90901e426413a1a89ab13456beac0872345ac03289bae1bbb0586a49f2d05886432bf7aabb919965646c41316c4d123e35ccdb2072d5d6c34b24944885dca9a66c6ee99ec64b52bed1e3e7035a2549dbf0cfc7774a6b03a67494e546afbf20d7456b44433f335690f7ec0f722a90d1c;
        #10 start = 1;  // Start computation
        #10 start = 0;  // Deassert start signal after one clock cycle
        wait(done == 1) // 1 billion time units at a 1ns timescale
        $display("Diff: %h", expected_results - result);
                resetn = 0;
        #20 resetn = 1;  // Release reset after 10ns  // Release reset after 10ns

        $display("Test 8");
        in_a = 1024'h61eae3321d742cbaff5f1d1419731b7b0d78b8eb08726bb83e2ec120806aaf82aa9c224c754ba370e8f34ca20a18f18118ac51f0e270e8398ca7e69542bfeb4e431d84efa89140c2679df4b9db2ba9f15107a117c91fd0e6580e313ce6b440d98517e4cee909600e7dd3ce9ca5aa581b338de69d6115e14e4430dcd69314d0e;
        in_b = 1024'h1e1df0ba77802293ec198da368f4340a8bff1961be9e1d40d7c0458864f5b96f217d5e42e485487e5a659d4ddf97eb3758831037f11adfdfc9140f5417730a68b10a4122d2bf757876649b0c303470df014015af3b630c69c8f8bdfc56277164ea73cd84e51b43ddfbc54812fd0c305fd7f2888829d250f2e13b94d39b7cc09b;
        in_m = 1024'h83468acf78d039947a7fd1f09b6c977f91f9d547b459d74d3194527769069adb7e10e1dfefc2454b075562e3b2ae5c0949cdd0ea3fb3b6089ad19b765b1524a23ecdc4b2660f043533f10db9bde55aa2a4e261ef1590dcb25deaad17280caa9227ce1ac0738a1a8e8d8abadfa1165ed238111681d5101ff169921270ba880a3b;
        expected_results = 1024'h26aadd2996406726bc46d8fbb16966857cad09a2a4c37f3e2fcb24fe5070acf00b85d240056bff29f14f4f1da103309b5afe6616c190557e4d20c5faca0d4a993bbc77ae22de7b8385bb54560fd0bea3c2f3166859e52f1896a9ed4adae5746a3d31bb2008ea4702b3ac8b3404db3fb5bcf6b7ac9e9150f7afa2c4113e2da2f3;
        #10 start = 1;  // Start computation
        #10 start = 0;  // Deassert start signal after one clock cycle
        wait(done == 1) // 1 billion time units at a 1ns timescale
        $display("Diff: %h", expected_results - result);
                resetn = 0;
        #20 resetn = 1;  // Release reset after 10ns  // Release reset after 10ns

        $display("Test 9");
        in_a = 1024'had189e26486aaf1ae75951d6606dc3c1712d87a5c9bc541ab2544280f06f771ba48199c03bf4bcefa3620e07447a2731b845ac633964761bfd0e08bbc99eb6ed07beac1649f17f5cd81ea255c7c43f04678c268c9c2eb728832189905ee374bad8fcb62caa0334c7a7b6c028fff2636993a107c3c868b055ea91b1cc115dcfd3;
        in_b = 1024'h39c509d1a2b21c12c41c62e91cb7eebf5ca01d8c7b4db45950c84cb27fd9b552337d521239d99c47418ea498ebc85e6c123fae0168b6c1df8632422c6e79b4e92284a3e4142104b6134bd7bebc8ce1be1caf8dc0dc1612d8ca8e539b96a53525f332c2aee82f7dd9bfe2c8c945793f11cc5f01739c06b9cbca3be9a032451c6f;
        in_m = 1024'hc1a87bf66084d72a1cbb0b5196f7848e383c90849a7af2b30260b04d1148eddb5689177110c0226e14c5bb610e27aae63b12a26759736e606136247d62a74954cea09b41d76273f915d5d476753093c852442959d6960482e3a5e881ddea4884b7e8c2bb6ab67c27a12fc6aed4e61eaea0782ce93235fbd2b628f11b8167635d;
        expected_results = 1024'h4a93450c347a49f84008967c243fb28ce81dbb9fbf21ee128f6c4391975ad474c0e52f4d5d72e436e45e5acbee40e53ec538e76ac42918524e71640b95eafab72a785f2cbb5c32314f5b3f9db3b608f814ebb4eb37f9157530ef4be64396a1beb197f449f18767a6ca9c6abda6b4b535bbe9b71e0cb701f43bf258074529d612;
        #10 start = 1;  // Start computation
        #10 start = 0;  // Deassert start signal after one clock cycle
        wait(done == 1) // 1 billion time units at a 1ns timescale
        $display("Diff: %h", expected_results - result);
                resetn = 0;
        #20 resetn = 1;  // Release reset after 10ns  // Release reset after 10ns

        $display("Test 10");
        in_a = 1024'h4a3f08a68e759d7c42ccf15a041232bb773a887df189ede75e990744289454ee4e687d3ed370bffda50506c9cb9d1862e32765ac6c704e34a978e9020eaaea0a0493e86c3d082b29f319595cbb4e96531d80d92c333a1cc5b507a322d798fce9d29567f1e4954b5c1499335f7f5f19cc706f5470ea142709064effaee76c2040;
        in_b = 1024'h25772e63b37440fd3dcc86a09987c1987331d9df1159a5a7f21bd7e33f96455c9179a597c760c9e02f20fa17ffdd9892b982ca0e0fa29d2e613d58d31b88256cda7bb93917ecf4a62e7ec4b77c0108d486f84d8c5f04cbd058c5287471c9111086a2f22d359ed375454eecde26d6f95f8d1e60e15ac2e9e4e6d5b8467041df1b;
        in_m = 1024'h87903946cd65fb34bc62c64b95757ec811bc3e891c0a6e13e3fa0b35b666bd28aed293a0144e2de0ce5a8576890df108c34d59baa51f53c25921ee4510e8045b2d2336a5f9205325bc4606859761b15830a2b739b30e1c7926efb088c9afe20e3e4b61741841138694c34cfccce103c640635b0b94f1617be0fa31d95836616d;
        expected_results = 1024'h7f880dbe12b5b0386c7652883fe819cb62f217fcd1bd6ee3afdfcfee036fcd533f89f4d0a7c1dd6f3c58607306ff12114a4fab8c906f4beaeb98b8c5217a4cda4b0f2e7a607f9ef8b89058a3f295abaeb4c423fb3a3cb5b516fdb4e5ad52477321e9f0ed13fa814d74fcfd8400debb129b8423c4ef2aae951c5469645de30988;
        #10 start = 1;  // Start computation
        #10 start = 0;  // Deassert start signal after one clock cycle
        wait(done == 1) // 1 billion time units at a 1ns timescale
        $display("Diff: %h", expected_results - result);
                resetn = 0;
        #20 resetn = 1;  // Release reset after 10ns  // Release reset after 10ns

        $display("Test 11");
        in_a = 1024'h92e0380b92aebc2108a11f828b86a27c86671b96484649da83d68b8dce5b6e29a92becc10b2f520e9288b9f29773081d5d7c521a057b3895e6bf7629ec27e702f149caf4e857eb372fba5515394e95589e66d8119e39e989432a8a130e79089be65edbb97aba4f08b112e066ccec5cc1a87ab2ae3fef2169e6c323478b573477;
        in_b = 1024'h2c73ced6c7fe196260bb85cfa1e05a52482c5686583d7b0f678fb3dbfda457bd5759afde46f841908a72b424623cb813bbf874bc8d8ae3116ac2b82128e22848d7302b6146d59ab31c35976857923e341522d43b44b6809ab2ce12bbd756d864e30b50d267a33e1f42648632023ee934ee93209007a28b77a780487132dda240;
        in_m = 1024'h96c19930c0c9425771c02bc1aa7a5e54461babf852dd080d3c97fc41caf5a33bd09564349d0b45383c28ee6b230bf15eefeb9824b28eb0e36cdc576f702ae61918de6ca394c6464e8abb36cead030d8aebd53d4dac4126fa3d02307d047cbafc0ac20d3f6a347d407001c81ac7d9bb9eeeceec59ebe942b9dd5c7b486150e651;
        expected_results = 1024'h92363563c83e52e0355c9b7cc4cda3ed1723a02f2a1363dd80bda0f5856ee0cf23df9ca2b6f1e29c2d2022d278b50998d587ed61f0b85f785bec77e6e20a4d5b752730fa5eb76ee0566274fe5114e32891d0e369814d46ab4446bca0d3a6546fc855fde6baeb779456c958c22fa0be76c16cf14d91de5364a795e39ac798e207;
        #10 start = 1;  // Start computation
        #10 start = 0;  // Deassert start signal after one clock cycle
        wait(done == 1) // 1 billion time units at a 1ns timescale
        $display("Diff: %h", expected_results - result);
                resetn = 0;
        #20 resetn = 1;  // Release reset after 10ns  // Release reset after 10ns

        // Additional test cases can be added here as needed

        // End simulation
        #50 $finish;
    end
endmodule
