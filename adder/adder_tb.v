`timescale 1ns / 1ps
`include "adder.v"

module tb_mpadder;

    // Inputs
    reg clk;
    reg resetn;
    reg start;
    reg subtract;
    reg [1026:0] in_a;
    reg [1026:0] in_b;

    // Outputs
    wire [1027:0] result;
    wire done;
    wire correct;

    // Test values
    reg [1027:0] expected_results;

    // Instantiate the mpadder module
    mpadder #(.ADDER_SIZE(257)) uut (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .subtract(subtract),
        .in_a(in_a),
        .in_b(in_b),
        .result(result),
        .done(done)
    );

    assign correct = (result == expected_results);

    // Generate clock signal with a period of 10 time units (100 MHz frequency)
    always #5 clk = ~clk;

        reg [4:0] test;


    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        resetn = 0;
        start = 0;
        subtract = 0;
        in_a = 0;
        in_b = 0;

        // Dump waveforms for analysis
        $dumpfile("mpadder.vcd");
        $dumpvars(0, tb_mpadder);

        test = 5'b10101;

        $display("%d", $bits(expected_results[1027:64]));
        $display("%b", test[4:2]);

        // Apply reset
        #10 resetn = 1;

        // Test Case 1: Simple addition of two numbers
        #10 start = 1;
            in_a = 1027'd1000;
            in_b = 1027'd2000;
            subtract = 0; // Addition
            expected_results = 1028'd3000;
        #10 start = 0; // Deassert start signal

        // Wait for 'done' signal to go high
        #100
        #10;

        // Test Case 2: Simple subtraction of two numbers
        #10 start = 1;
            in_a = 1027'd3000;
            in_b = 1027'd1500;
            subtract = 1; // Subtraction
            expected_results = 1028'd1500;
        #10 start = 0; // Deassert start signal

        // Wait for 'done' signal to go high
        #100
        $display("Diff =%x", expected_results-result);

        #10;

        // Test Case 3: Edge case - large numbers addition
        #10 start = 1;
            in_a = 1027'h5037a57ca996db568fd681b0eee5660d8b1bac3f26d4c7d4bfd7569cea79a145a1e92496b29b0ef27b1f1138ef99808032375ae31820c93afee07f59b71f0e9205b2df5de5917242015ab0523b77d8245cab5c51b0ecfd3a04343fefd3da2e2f847a2628d9042682c37ea70249c53f1044691d3d8640223354bab205a3d87c0c5; // Maximum 1026-bit value
            in_b = 1027'h57094adfb92250358e5b00f6b91f711ce3d00dcd6651b2d9e99f080272a4067278e091cd48a8afc8c898f3a6c438ad9c940c8783c45054fde3c9926381f52222525b425eab03e92e43ef615df37a8b6cde00524ff913662ac768b37a8361c968d9304f920b7f1f278daabc7fa237c56112df9aeab7534a3f5fd7163600e67b0a9; // Slightly smaller max value
            expected_results = 1028'ha740f05c62b92b8c1e3182a7a804d72a6eebba0c8d267aaea9765e9f5d1da7b81ac9b663fb43bebb43b804dfb3d22e1cc643e266dc711e38e2aa11bd391430b4580e21bc90955b70454a11b02ef263913aabaea1aa006364cb9cf36a573bf7985daa75bae48345aa51296381ebfd04715748b8283d936c72b491c83ba4bef716e;
            subtract = 0; // Addition
        #10 start = 0; // Deassert start signal

        // Wait for 'done' signal to go high
        #100
        #10;

        // Test Case 4: Edge case - large numbers subtraction
        #10 start = 1;
            in_a = 1027'h6a26b6195145db76f720b63f19f8844a6a3e6801ff7bd0d62949563cce5ea2f66e14a3c862d706bd44db1b6ea65e84b5ea9f958955a8a2fcb397a1a11f2ac168eb388d8ab437bcca0fce5d8a5e16cb726bfe06c35ec0631672102a495598b6a803d04a2d67351297accdbdec0e46d3c4784d46f3d20832d050d5b65d5cb0474e4; // Maximum 1026-bit value
            in_b = 1027'h4e5d2a0b6da45e13044a6596d0b5200547e40e18abb2eff5d07226cb694813af04d61b44d0e18de8220298844f81a262378d23c4c1849106db5fb6ffd82a90622b33f832a740c3929f2cc8eb7aef7de89c6f982179ef0d1d28338d61e056df1f51cb4e811c6e6a5b90e7078e5e89aade568659c2d327c79488b57eb53575398a8; // Slightly smaller max value
            subtract = 1; // Subtraction
            expected_results = 1028'h1bc98c0de3a17d63f2d650a849436445225a59e953c8e0e058d72f7165168f47693e888391f578d522d882ea56dce253b31271c4942411f5d837eaa147003106c00495580cf6f93770a1949ee3274d89cf8e6ea1e4d155f949dc9ce77541d788b204fbac4ac6a83c1be6b65dafbd28e621c6ed30fee06b3bc82037a8273b0dc3c;
        #10 start = 0; // Deassert start signal

        // Wait for 'done' signal to go high
        #100
        $display("Diff =%x", expected_results-result);

        #10;
        // Test Case 5: Edge case - large numbers subtraction
        #10 start = 1;
            in_a = 1027'h0; // Maximum 1026-bit value
            in_b = 1027'h33c211b567e0c0ce6610393b49e77a5fb33183f2ef3bd0c34e15369f3537c592b927242339b723be6c59d907c2cbef8d6afee9803ed39bc4fe2f7773546ed91771322659fdd65ad3402f62be5f34bbdf7ca9aa874d678a9decb13abe8b9c3badbdb709dfee20ec628be2748831cac28e1e027e33eeb69ff23499dc429d74a517; // Slightly smaller max value
            subtract = 0; // Subtraction
            expected_results = 1028'h33c211b567e0c0ce6610393b49e77a5fb33183f2ef3bd0c34e15369f3537c592b927242339b723be6c59d907c2cbef8d6afee9803ed39bc4fe2f7773546ed91771322659fdd65ad3402f62be5f34bbdf7ca9aa874d678a9decb13abe8b9c3badbdb709dfee20ec628be2748831cac28e1e027e33eeb69ff23499dc429d74a517;
        #10 start = 0; // Deassert start signal

        // Wait for 'done' signal to go high
        #100
        $display("Diff =%x", expected_results-result);

        #10;

        #10 start = 1;
        in_a = 1027'h5770722ac9c75750197b73f03c1707ebee9f13c343adb203982dd8fe753ba2b3d56121ea5af5a7f46d4067726b54bf2ea271ca294ea4bffa1b225d6876bddbca7c8b98658723ed8c4fb25e1e342c1d6d548f964260e1f289016f7e6dcbdb67077160716e92d7339771bc452bc5185724f7e61714f5c3c1cefcfff9200792310d1;
        in_b = 1027'h79553fb235ab029e5e8c2ac23bb4f33656ccd2afa14df4946c017d9adaa087f40375bc23066f6334b6bebab6fa90a60f61bc9406e19bd9f16278a602d9ec3daa34ea029818103605c4f267b3b7a71bf5a4220542b99e438fe9b606f5a8cda5f837d39c467dfd454d0bb29e988fdc5b3631b22bb715907fc2e59a6d835504df97d;
        subtract = 0;
        expected_results = 1028'hd0c5b1dcff7259ee78079eb277cbfb22456be672e4fba698042f56994fdc2aa7d8d6de0d61650b2923ff222965e5653e042e5e30304099eb7d9b036b50aa1974b1759afd9f34239214a4c5d1ebd33962f8b19b851a803618eb25856374a90cffa9340db510d478e47d6ee3c454f4b25b299842cc0b544191e29a66a35c9710a4e;
        #10 start = 0;
        #100
        $display("Diff =%x", expected_results-result);
        #10

        #10 start = 1;
        in_a = 1027'h542e90b9fb0672a85e5a3d4ca891fee5467cf1e7fca775e6e0b9534d4e69d778dd705c8e868d02679f7562f547524547833b129788f60f6b9de501241fe37ea9058b59ee31704e495a88179c1015f7cd6a9f85cdfbb7b8e95e370fbd4b9e7f5001c1ae83ab6f05af55bff846c24e89ac92451f2679acf7248143c9d784ae8d7c0 ;
        in_b = 1027'h70d38357b1f8db7455f4cad87ac91ea269e6f56355d8c51c4c91886aaa263c449fa52bfbd662ffb21f860f0cd2d9f946fe6731a65bedf8d9861f9fbfc8ee93524a987aff0cf23a182e98fe9827fe8d927a9de2f0a2a905b6354797104bff5cccf4685ee45d83a96adfa6ec4e2456727cdaecca64164922d88940f96814d655485 ;
        subtract = 0;
        expected_results = 1028'hc5021411acff4e1cb44f0825235b1d87b063e74b52803b032d4adbb7f89013bd7d15888a5cf00219befb72021a2c3e8e81a2443de4e408452404a0e3e8d211fb5023d4ed3e628861892116343814855fe53d68be9e60be9f937ea6cd979ddc1cf62a0d6808f2af1a3566e494e6a4fc296d31e98a8ff619fd0a84c33f9984e2c45 ;
        #10 start = 0;
        #100
        $display("Diff =%x", expected_results-result);
        #10


        #10 start = 1;
        in_a = 1027'h779eba265453974c572e28e9e35a69abe41da74bfe86ab02f47e497bb34e64d1495fcdfbc88dd62d082e249dc6945ee84d285b0c41d4415decab4a205213ead5a3911e15a800c99412471193ec68e6024d69ce33fca2c4947174d814f652da10feba17dd14dcefc6749dd9599fb13bc179727d9b0050320cbd346e4ddb5f66541 ;
        in_b = 1027'h55bcb7afa016cf5873aa539d5de58fee727a148029898140d6f7db86e7a522f14383f0bef70c8330e01b7f317661c6175eca0fbef0a9c7b30eab1f9a07ad26e8aca8967a8e9ddfbcfa6f18ef50f4bfb113fc8f995c46d0fc51d3b13b4a7b533a205cec80c4a82ac0883cfb3476d55f8230d71c56d25ea8d26e5f57968ecf87295 ;
        subtract = 0;
        expected_results = 1028'hcd5b71d5f46a66a4cad87c87413ff99a5697bbcc28102c43cb7625029af387c28ce3bebabf9a595de849a3cf3cf624ffabf26acb327e0910fb5669ba59c111be5039b490369ea9510cb62a833d5da5b361665dcd58e99590c348895040ce2d4b1f17045dd9851a86fcdad48e16869b43aa4999f1d2aedadf2b93c5e46a2eed7d6 ;
        #10 start = 0;
        #100
        $display("Diff =%x", expected_results-result);
        #10

        #10 start = 1;
        in_a = 1027'h693f725c1a4e41d4d18f9e8f83e19f2a3f1c6b77456a2a6332c09409f9a85a42ebc655ff9b67da0e452155e709e105ce4ba32465933def7896bb92f5201952f4bb0fd86f0e4f2414ca44fdb3fedbb06cba0433318bcc9acc0efd8e9992e7237383b9aa52a9043e4f24361ef82a5c2bde30ef9c13b0ea243d554911e1d4310703a ;
        in_b = 1027'h42e88a39280d7f5a32a578c323e8511e33cfaa15d343fe01598ba71f631a791cfb2e66c2922e318ae5b622f4b010144600171b90f8ebf1c9bae57ac6b0454aca7244b99b20ad0b4b3b5d63da5ee16f5c1a183e649559b71b8ec897255da5ce2a1aa2df772ae6a7659114036d7eeebda493dac3e862e2e9dafb7ded6474c2548b9 ;
        subtract = 0;
        expected_results = 1028'hac27fc95425bc12f04351752a7c9f04872ec158d18ae28648c4c3b295cc2d35fe6f4bcc22d960b992ad778dbb9f11a144bba3ff68c29e14251a10dbbd05e9dbf2d54920a2efc2f6005a2618e5dbd1fc8d41c7196212651e79dc625bef08cf19d9e5c89c9d3eae5b4b54a2265a94ae982c4ca5ffc13cd0e1850c6ff4648f35b8f3 ;
        #10 start = 0;
        #100
        $display("Diff =%x", expected_results-result);
        #10
            
        #10 start = 1;
        in_a = 1027'h6c64a80a829467c11e7ba53a151f4673ac7b634993ef514f2e8f067bfee7ec17f484bacf4ed07391f7e927da891708d1ec2c7a5a32abeb8cee5606aaad744eccb936c9264a98ecbd215c51d86bf8f170128b4eb84f3ad3121f94dcddbd25b00eb0c1bbadceca7203e152528b4aedb0ece394118b278439f8a00c73dbb0d7960dc ;
        in_b = 1027'h7018e920df62cbd77b0be9e00f15bd8aa7c2f6794b3404b378419249313d05e0bd828139b12d73b11975f25b707de3c3e0f3c1ed5f1c8a0348532e3006d2ceb7d89a048d515c4cb1bc07640f00789ab4e5c771539af370a42c2057d91d3fe58bdf1dba8392bac2b9f6b92df20cc70760d20404cad271a389cbf855e698833d1fa ;
        subtract = 0;
        expected_results = 1028'hdc7d912b61f7339899878f1a243503fe543e59c2df235602a6d098c53024f1f8b2073c08fffde743115f1a35f994ec95cd203c4791c8759036a934dab4471d8491d0cdb39bf5396edd63b5e76c718c24f852c00bea2e43b64bb534b6da65959a8fdf7631618534bdd80b807d57b4b84db5981655f9f5dd826c04c9c2495ad32d6 ;
        #10 start = 0;
        #100
        $display("Diff =%x", expected_results-result);
        #10

        #10 start = 1;
        in_a = 1027'h6d955c8d1693b76b6755175941b74adbb1c4751290d4d7ca0d022cdf9dc6092e6e1ba9a1b928e62a3bd81e4e19ce18fe958f8f539c6761ad676e98c4ecb4b98a4ce3153b66316499c61f337b5244660ec2a47dca427cd641c1f9468811af8e091d629d6c959bea6c24dfef5e1339debfb76905abade2b35ca0d167061ba1f9578 ;
        in_b = 1027'h62f353fd40ca737b24344f08fd4608d423bde9c69c1e54c9fcf0e725c4f279dcec333401db619a18678f4b449f02b71101548b00a2731dd4a71fd72895dce505418c5926c60f51d43775678850f514bfe2ad612fc1f2ad8eac7928de1f1a2a345a8adf652b290754bcf01ffff130ad293580472b95d8feba541f918d1b329aa4d ;
        subtract = 0;
        expected_results = 1028'hd088b08a575e2ae68b8966623efd53afd5825ed92cf32c9409f3140562b8830b5a4edda3948a8042a3676992b8d0d00f96e41a543eda7f820e8e6fed82919e8f8e6f6e622c40b66dfd949b03a3397acea551defa046f83d06e726f6630c9b83d77ed7cd1c0c4f1c0e1d00f5e046a8be8ece94cd743bbb216f4f0f89336d493fc5 ;
        #10 start = 0;
        #100
        $display("Diff =%x", expected_results-result);
        #10

        #10 start = 1;
        in_a = 1027'h67e54780ef94606b1c52dfed0d65cd6f969caf24cf5aa3b7edf4789c044d79bf1c87231b274cd1d5c2ee6e8c733b9e09aceefe3d1d75b4a174d42712f2236775972f75a16675c49c7dfb6f692d76136bb749442cf0584df24e92cc722464a0934ec6d02ae8e78cc96d881d5e884a7cda31eaa3fb9c81d22ec784094904d463829 ;
        in_b = 1027'h5c7ad5df99472686595ff3db68badb5c1cbde56bc990166a712499cfe9c13c615565d39b048949a8b91538a00b68892fd099df91b33d6d82585983065375ab759e8af599722c18ccd332376b0519d03d9a2c6a659940d11953a010a61af78d8f95d82029b794073a547e0568b841e002c02cc1aa21576eb73285b75cd966d651e ;
        subtract = 0;
        expected_results = 1028'hc4601d6088db86f175b2d3c87620a8cbb35a949098eaba225f19126bee0eb62071ecf6b62bd61b7e7c03a72c7ea427397d88ddced0b32223cd2daa19459912eb35ba6b3ad8a1dd69512da6d4328fe3a95175ae9289991f0ba232dd183f5c2e22e49ef054a07b9403c20622c7408c5cdcf21765a5bdd940e5fa09c0a5de3b39d47 ;
        #10 start = 0;
        #100
        $display("Diff =%x", expected_results-result);
        #10

        #10 start = 1;
        in_a = 1027'h4a4a2a89ac6f9916a738664a9355ca1f1a0e23794e0d409c8d61e5830149e0f65e060dfddb8273636f5ac1faa18b73d6d3c41630fca228efff4197a3f435b61019a816734ba0f9f5903bd550ec87e36baed6bc7231d921db42a689b3d54ad0099ad370ff7b56bc6eda977705f485dba1016f5c5c2bee399d8deddbe093059bae0 ;
        in_b = 1027'h7e60cba3db3ffee099d864894d912ae048a52925414194e47b3bc2e8518d2554172156b3fb4414ea87d71474ead0f5368cd500f4982269009708569e9b01f2270b09b0f0d86c63de54138ccab44f9ab03698a58047df1d35b3f455dd3867fa9044969fd3024c0c453b6a4b94afd28b3d941624d3981b04ea757c291ae774e8891 ;
        subtract = 0;
        expected_results = 1028'hc8aaf62d87af97f74110cad3e0e6f4ff62b34c9e8f4ed581089da86b52d7064a752764b1d6c6884df731d66f8c5c690d6099172594c491f09649ee428f37a83724b1c764240d5dd3e44f621ba0d77e1be56f61f279b83f10f69adf910db2ca99df6a10d27da2c8b41601c29aa45866de9585812fc4093e88036a04fb7a7a84371 ;
        #10 start = 0;
        #100
        $display("Diff =%x", expected_results-result);
        #10

        #10 start = 1;
        in_a = 1027'h589ce89ca07c2ebf68314a9f6812da2cb6ff2b4bf5fd3e5beccaef04fefcceecca378730c824273bd06a252eefb2f6694c046ee38b64dd39976d2d87c0347316d891ff12c7e3d5051cd3960b4df51ca01ccad23181b4ac13e7b6ce06de7d041f6237eccf929652975c4ae2f71de0f78764da18c09f7ec3492d547de2dcabbc718 ;
        in_b = 1027'h420d6eb4ff2b41b0d9c7af9c2fea396233e7e7f012e87bd29ca66bf93aea488f0e7a91454a8278545ae4c161ed6558340a79d9a5f36dd8121e03bbf9be66735a94fb3b955557b53f2218e5e08ad48599027d20ebe897f5bc7d8afc19aeeabc09901feaedfced4d27427ea61ee21b12537fdf00fe3b7cb8be372f9237af2e8902d ;
        subtract = 1;
        expected_results = 1028'h168f79e7a150ed0e8e699b033828a0ca8317435be314c2895024830bc412865dbbbcf5eb7da1aee7758563cd024d9e35418a953d97f705277969718e01cdffbc4396c37d728c1fc5fabab02ac32097071a4db145991cb6576a2bd1ed2f924815d21801e195a9057019cc3cd83bc5e533e4fb17c264020a8af624ebab2d7d336eb ;
        #10 start = 0;
        #100
        $display("Diff =%x", expected_results-result);
        #10

        #10 start = 1;
        in_a = 1027'h5b7b85bff54e5d1d1c2453bf16243cc3f1b4388e3b7b4f2b63c5fc8afe2dc01db6d8beb79113124c2969a1ecea323598cc77e47ec6ac3cd0a7cb600401564dfa1fe9752fce83331a29a5f0a342f8e5ef52dd376d64a997ea70c76a36f09138a460f00c80edb2883009e37b81e356afab218f883ac6ec02f56961c17e4eb5ba311 ;
        in_b = 1027'h7cd519f86665a9d9943b7b30b8705d325f51214fca10d874920ca92bdb1de0bdd02fcbe97e29234c9130f566e5c0e5278ac335d1b957223ff767ecef99efe05ded6aa8b34a2da1b4d0a44a0e55599dd971717f0dc72137bc42a3b4b74d953cf340816ff08cae262385b3d3a30565556a77c95019f9ff89874c9e57c28a8354700 ;
        subtract = 1;
        expected_results = 1028'hdea66bc78ee8b34387e8d88e5db3df919263173e716a76b6d1b9535f230fdf5fe6a8f2ce12e9eeff9838ac860471507141b4aead0d551a90b063731467666d9c327ecc7c845591655901a694ed9f4815e16bb85f9d88602e2e23b57fa2fbfbb1206e9c906104620c842fa7deddf15a40a9c63820ccec796e1cc369bbc43265c11 ;
        #10 start = 0;
        #100
        $display("Diff =%x", expected_results-result);
        #10

        #10 start = 1;
        in_a = 1027'h577355291ff84ceacba1e180420895fff13f8a19a9858cc6f469e630d365ca17767449f070e2dc3fcbca8a6a786b0d447ddaaa53df827d3fa4aa50dd646638b7b89534a2852da0b6b7449634599fcb7fd463e1c7154ae7f22479f61baf6db4a921507309665d82305ea4fce99528008421e0fc709579ecce620814c27460690fb ;
        in_b = 1027'h74c785f2f51db926701a5b1b7a8940ed82f596d4f80bee2fee68155543dc3407c3096e0e007529a551ab9439533b23df7cb86445fedda0560ff40659e80a2ed94ee918f8159cf796a7d4cf7a17e923e9bacefd342aa69682a5fcc97e15a4eff787a090866e5dff67e3e102addc8a4b32e0274e2afa8adcf31faa088c0d0bd991e ;
        subtract = 1;
        expected_results = 1028'he2abcf362ada93c45b878664c77f55126e49f344b1799e970601d0db8f89960fb36adbe2706db29a7a1ef631252fe9650122460de0a4dce994b64a837c5c09de69ac1baa6f90a9200f6fc6ba41b6a7961994e492eaa4516f7e7d2c9d99c8c4b199afe282f7ff82c87ac3fa3bb89db55141b9ae459aef0fdb425e0c3667548f7dd ;
        #10 start = 0;
        #100
        $display("Diff =%x", expected_results-result);
        #10

        #10 start = 1;
        in_a = 1027'h5061664f28644cdcd3490ca8b43ab53902deadb89168694a904b0cf7c69ab0d07f092b41a7e6a4a50b8756de4d9770c31ffe2aa42cb50fa8e442464f7fae545ac61c653a13d2f3fa93a64c6fd0141b24c5700884332334ec97449f7f0818996c450b6ea446d40dad011810b16de4f2834f8eeaee034209ac4ab03a6b2ca0aadc8 ;
        in_b = 1027'h78463e82dc29806d389435a080a458b9aa665be070b0249ce0a6adfa8280b082fd56010819828da8b281024562587d0253f80b532610e39488a46942e6135e5ea6f4bd1a54ad4e9eaa933d98e695c9d98fea218ab1e643b1854fee3f0e6697e14df19a7fa1783b16d78e05c907172f4cd203688b36653a7a7bd29ce55b44cc971 ;
        subtract = 1;
        expected_results = 1028'hd81b27cc4c3acc6f9ab4d70833965c7f587851d820b844adafa45efd441a004d81b32a398e6416fc59065498eb3ef3c0cc061f5106a42c145b9ddd0c999af5fc1f27a81fbf25a55be9130ed6e97e514b3585e6f9813cf13b11f4b13ff9b2018af719d424a55bd296298a0ae866cdc3367d8b8262ccdccf31cedd9d85d15bde457 ;
        #10 start = 0;
        #100
        $display("Diff =%x", expected_results-result);
        #10

        #10 start = 1;
        in_a = 1027'h5b059bf2d2fec5d4a5988021bb7c6b5084529dd259b3ec54a9d79870e5959c615c8eec766006f9ca9e2e4a03aefef20ecd2cfc48e736eed4bba9b48099adfd455e0376cf45cb693ea9d9dea7f9d611042dae84ec25af09d487b4f32840fda8b2e24c557efc21684e0e596fca1c545920b6be17e6f0aac4c5f09c7d9efc59038e9 ;
        in_b = 1027'h526655d7dca297ba913d7091db8dc52fc3dc08f5143ec7fa9af869de4202b14bb432ae4b661e070f297da64066748e4a3a249123ccf64274bb3dc5c01f9c7b5b966406ff51ff1b41b12c9ae8af2a75b27505742f3a80d04112f015d188f91a336cb1c421125a49576784f528bcb821a6f79dbac38c1f89dbc21d384e1d119de47 ;
        subtract = 1;
        expected_results = 1028'h89f461af65c2e1a145b0f8fdfeea620c07694dd4575245a0edf2e92a392eb15a85c3e2af9e8f2bb74b0a3c3488a63c493086b251a40ac60006beec07a1181e9c79f6fcff3cc4dfcf8ad43bf4aab9b51b8a910bceb2e399374c4dd56b8048e7f759a915de9c71ef6a6d47aa15f9c3779bf205d23648b3aea2e7f4550df4765aa2 ;
        #10 start = 0;
        #100
        $display("Diff =%x", expected_results-result);
        #10


        #10 start = 1;
        in_a = 1027'h7f82ffb61f2f8e4343e04764ec3b92ca9809d0ae02be2b9ccc94c68d6a95e99224b4ec9570c84e1768f102017a33b66148258c0470ddbc703f47e212eafb043905d95365d9369dcceabba371703006fda1a25faac99898e03345a40253d2bd79ea6df3a87232be217f1c39f990a6b165f6bb86d4fbc3ab55bdb18286161ea861e ;
        in_b = 1027'h52792547566678fff7eb8fc9a20c3eb31c27fef151a66a68044f6de0c0555162f523eb74b07b9f3cf1b27c4bbcfca497dd07e9be150fe285ec067307c572e8bbc249b79408e7c80a6ce21d4f9824cb46be1361164ac51b525363f724dfb787b71ef7f836428c8609cdcdd00a7eaf949090fd31bce924c8a3733fea9f63478ecae ;
        subtract = 1;
        expected_results = 1028'h2d09da6ec8c915434bf4b79b4a2f54177be1d1bcb117c134c84558acaa40982f2f910120c04caeda773e85b5bd3711c96b1da2465bcdd9ea53416f0b25881b7d438f9bd1d04ed5c27dd98621d80b3bb6e38efe947ed37d8ddfe1acdd741b35c2cb75fb722fa63817b14e69ef11f71cd565be5518129ee2b24a7197e6b2d719970 ;
        #10 start = 0;
        #100
        $display("Diff =%x", expected_results-result);
        #10

        #10 start = 1;
        in_a = 1027'h4e62c012e79a5dc8ab6ae96a0b8ba5b6158ccce6fa6b6f8079a37dfaaa040bbb2a1d7d0f76d4e5b2db17fe2f58aaa93f8cd085114446a6d0c2693a64be567ea3a8cab82920f89b4698eef5672047c2b6ef6c3faaaba87b9c5594b668baf380a8d62512092f231968a762a8bd8014d7a1cd98cd20ccac8858ef59b45d9b57a7b02 ;
        in_b = 1027'h61e3785cefe110f8878369ee0ca235d09c3f8d5d42d71c0535918664f72ffaab2c0732ce0ab00af535632d1871fc2e2eec741debf0520b24ed87137b8726de366fe1febb01ac0682e19c90b6fc1604a8ce829a9062fdc4b4b0041f76ff46ba7133b1b965ab1b4f3723212d792788cdfed54d72c6b914c6f2eb582fa80f8611da6 ;
        subtract = 1;
        expected_results = 1028'hec7f47b5f7b94cd023e77f7bfee96fe5794d3f89b794537b4411f795b2d4110ffe164a416c24dabda5b4d116e6ae7b10a05c672553f49babd4e226e9372fa06d38e8b96e1f4c94c3b75264b02431be0e20e9a51a48aab6e7a59096f1bbacc637a27358a38407ca3184417b44588c09a2f84b5a5a1397c166040184b58bd195d5c ;
        #10 start = 0;
        #100
        $display("Diff =%x", expected_results-result);
        #10

        // Finish simulation
        $finish;
    end

endmodule
