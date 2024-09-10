use core::starknet::ContractAddress;

#[starknet::contract]
mod Syndicate {
    use super::{IERC721Mixin};
    use core::num::traits::Zero;

    use core::starknet::{
        ContractAddress, contract_address_const, storage::{Map}, get_contract_address,
        get_caller_address
    };
    use openzeppelin_token::erc721::erc721::ERC721Component::InternalTrait;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use openzeppelin_introspection::src5::SRC5Component;

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    impl SRC5 = SRC5Component::SRC5Impl<ContractState>;
    impl ERC721 = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721Metadata = ERC721Component::ERC721MetadataImpl<ContractState>;
    impl ERC721CamelOnly = ERC721Component::ERC721CamelOnlyImpl<ContractState>;
    impl ERC721MetadataCamelOnly = ERC721Component::ERC721MetadataCamelOnlyImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    const DUNGEON_DUCK: u256 =
        549461316660383711029159810588666885992563315130734890670015212820367409155;

    #[derive(Copy, Drop)]
    struct DuckHolder {
        address: ContractAddress,
        count: u128,
    }

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState,) {
        self
            .erc721
            .initializer(
                "Dungeon Ducks",
                "DD",
                "https://api.briq.construction/v1/uri/set/starknet-mainnet-dojo/"
            );
        _airdrop_ducks(ref self);
    }

    #[abi(embed_v0)]
    impl ERC721Mixin of super::IERC721Mixin<ContractState> {
        // IERC721
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            ERC721::balance_of(self, account)
        }

        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            ERC721::owner_of(self, token_id)
        }

        fn safe_transfer_from(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256,
            data: Span<felt252>
        ) {
            ERC721::safe_transfer_from(ref self, from, to, token_id, data);
        }

        fn transfer_from(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
        ) {
            ERC721::transfer_from(ref self, from, to, token_id);
        }

        fn approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
            ERC721::approve(ref self, to, token_id);
        }

        fn set_approval_for_all(
            ref self: ContractState, operator: ContractAddress, approved: bool
        ) {
            ERC721::set_approval_for_all(ref self, operator, approved);
        }

        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            ERC721::get_approved(self, token_id)
        }

        fn is_approved_for_all(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            ERC721::is_approved_for_all(self, owner, operator)
        }

        // IERC721Metadata
        fn name(self: @ContractState) -> ByteArray {
            ERC721Metadata::name(self)
        }

        fn symbol(self: @ContractState) -> ByteArray {
            ERC721Metadata::symbol(self)
        }

        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            "https://api.briq.construction/v1/uri/set/starknet-mainnet-dojo/549461316660383711029159810588666885992563315130734890670015212820367409155"
        }

        // IERC721CamelOnly
        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            ERC721CamelOnly::balanceOf(self, account)
        }

        fn ownerOf(self: @ContractState, tokenId: u256) -> ContractAddress {
            ERC721CamelOnly::ownerOf(self, tokenId)
        }

        fn safeTransferFrom(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            tokenId: u256,
            data: Span<felt252>
        ) {
            ERC721CamelOnly::safeTransferFrom(ref self, from, to, tokenId, data);
        }

        fn transferFrom(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, tokenId: u256
        ) {
            ERC721CamelOnly::transferFrom(ref self, from, to, tokenId);
        }

        fn setApprovalForAll(ref self: ContractState, operator: ContractAddress, approved: bool) {
            ERC721CamelOnly::setApprovalForAll(ref self, operator, approved);
        }

        fn getApproved(self: @ContractState, tokenId: u256) -> ContractAddress {
            ERC721CamelOnly::getApproved(self, tokenId)
        }

        fn isApprovedForAll(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            ERC721CamelOnly::isApprovedForAll(self, owner, operator)
        }

        // IERC721MetadataCamelOnly
        fn tokenURI(self: @ContractState, tokenId: u256) -> ByteArray {
            Self::token_uri(self, tokenId)
        }

        // ISRC5 snake case
        fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
            SRC5::supports_interface(self, interface_id)
        }

        // ISRC5 camel case
        fn supportsInterface(self: @ContractState, interfaceId: felt252) -> bool {
            SRC5::supports_interface(self, interfaceId)
        }
    }

    fn _airdrop_ducks(ref self: ContractState) -> u16 {
        let mut token_count: u16 = 1;

        let mut duck_holders = get_duck_holders();
        loop {
            match duck_holders.pop_front() {
                Option::Some(duck_holder) => {
                    let mut mint_count: u128 = 0;
                    let num_mints = *duck_holder.count;
                    loop {
                        if mint_count == num_mints {
                            break;
                        }
                        self.erc721.mint(*duck_holder.address, token_count.into());
                        token_count += 1;
                        mint_count += 1;
                    }
                },
                Option::None(_) => { break; }
            };
        };

        assert(token_count == 301, 'Token count is not 301');
        token_count
    }

    pub fn get_duck_holders() -> Span<DuckHolder> {
        array![
            DuckHolder {
                address: contract_address_const::<
                    0x0428c240649b76353644faf011b0d212e167f148fdd7479008aa44eeac782bfc
                >(),
                count: 9
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0015298fb05df6d2745498d63b886d2b44583079de593d897c5ce643a5cd95af
                >(),
                count: 8
            },
            DuckHolder {
                address: contract_address_const::<
                    0x052df7acdfd3174241fa6bd5e1b7192cd133f8fc30a2a6ed99b0ddbfb5b22dcd
                >(),
                count: 8
            },
            DuckHolder {
                address: contract_address_const::<
                    0x057c5f91dfcc92ddd02f496c9fa7994b8366f60a66a3a3e698af5d4628f5bde9
                >(),
                count: 7
            },
            DuckHolder {
                address: contract_address_const::<
                    0x00772fd980735735c92c68aa729f4849fba7fba2b478ad3d65b4d08ec6e91227
                >(),
                count: 6
            },
            DuckHolder {
                address: contract_address_const::<
                    0x001a9e0fcae83515b6ed40e81cbc4a4794110e60dcac28ebc6f327ae426244b1
                >(),
                count: 5
            },
            DuckHolder {
                address: contract_address_const::<
                    0x00a00373a00352aa367058555149b573322910d54fcdf3a926e3e56d0dcb4b0c
                >(),
                count: 5
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01ce157c614962af16ad3852e3bd26cb8241947495ca6c6c8afa9463c57e5f06
                >(),
                count: 5
            },
            DuckHolder {
                address: contract_address_const::<
                    0x05be5bce504cd384a60648930da38be10990b04b2681d5c0252965f3605fb698
                >(),
                count: 5
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0389388f69e52257688d6cda62293c839f2ad843b169cbc4c48071875da31ea9
                >(),
                count: 4
            },
            DuckHolder {
                address: contract_address_const::<
                    0x079591b119f3e3f927bb5d4730cd9aad84384498290df5a05134c2e41eb03434
                >(),
                count: 4
            },
            DuckHolder {
                address: contract_address_const::<
                    0x02fddc9276cca89e85449ed9c182e7938b2c2d246da464207e5b3cf17b413ab5
                >(),
                count: 4
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0055fee011a9268078a9c197dbe362df740adba760a604b7f3f78514b3d34ce9
                >(),
                count: 4
            },
            DuckHolder {
                address: contract_address_const::<
                    0x04f988922880c0d1003d8d52dea4529dfec49e3c39268e77622ebf1b22f28878
                >(),
                count: 3
            },
            DuckHolder {
                address: contract_address_const::<
                    0x009153c3344ecf28213b730c016751e838374da62a7572899f0e638094cd446f
                >(),
                count: 3
            },
            DuckHolder {
                address: contract_address_const::<
                    0x00363b7fb46bf72a2196cbb003ef3a1c2b0edebcf0716f31b0026b89b17e2227
                >(),
                count: 3
            },
            DuckHolder {
                address: contract_address_const::<
                    0x06bcb71ab3d080d8d89e919b65a1e13e99da0eaaf16ffd5e6d626f758a2f644c
                >(),
                count: 3
            },
            DuckHolder {
                address: contract_address_const::<
                    0x06130eee5102a77071c5bc03d6e910f6928c5e3d554e822db793c50942fb0106
                >(),
                count: 3
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0083ebc05dacaccb7e9a42e1e85130a454d19aa8ccf965ebc0eeb0ac53a1cbb8
                >(),
                count: 3
            },
            DuckHolder {
                address: contract_address_const::<
                    0x066289c724770bfbdbc4ae337b304f31e57b3766562a0e312f857f7857914012
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x064799e18603819e8e4327b8b1eb514d4ca6f619e68b73d51b7f27799a59f81f
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x030eb57fac7a8e55b169541c866517396648a8d90c4ec1115f76cdbc871fb527
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01368f255e82ed82ae74ff131a8f1cb5d63188f19f0ac77c7082ba4473e73b2c
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0564e6c571d969772dd9edabc917c556c39fa547a03f909791aa956a80f576fb
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x043ef00656285f1c1d11db93b608d3ec943da49fc4430599fe4774cbd86e9fa9
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01f447b1d086c66533b481311813a68cde116aacf39fb9611636f18c79502241
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x03d8c60d464f955649961d25db646a6b747f64bf94248f318305d686eba79222
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x03858f95e136b3ee520b224dbb7f6b1dc954d993fc773b73785ca949733fbd3a
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0079d57dd558fd1882cd30beb8490da8179694acc7756570b03cc4428ad54664
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x068df7fb9100fbc80599502287c4a973d790f6a241482d99bf6f1b421d659634
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x02219f39c380349b64f88c1cf91d9ea95d43f29d2eff90b6d9d3b81da44280b1
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0474e0febaa7dcb7855d6b0e4888ded6c353612e3901a22759529413d50d360e
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x04645f67e3e195420b2b4e63742153623e50c143ed8b89c91e3fb908fe87b168
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0108ba8b195239a76295c87a6f530eddb77fba10bcde9cf2fde3377b53197f5e
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x07f1609777e817175b6d04335ec5b54cccf5db64c2603d69adc82c38e00f0ca3
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x04042b3f651f6d6ff03b929437adc30257333723970071b05cb0e2270c9dc385
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x05547e736cc915ef3f475508a624d9c3c33da5856b23fe9d99f487dacea67a13
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x02b40cc7a6ba037c45a6e8eb31d45962123f19725c25f67fbb3a7668f4b0b7ba
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0128d3fbcbf7c1ac2f34981644ff44731fa8542c698070df54562ccaf5b0e9af
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01381dad4fb3d55cbc5e8a64ce07fc78a1cc0ec11dfb5ef68ce3c257fd66e25f
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x032cf696cf09d57848ccb251a0b9a1163d7e3bbe12856f275c46600f3e753826
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x044a4cf62fec355adba9ba1f3122a08c6ccf7819d524efb7ca549ca06244cc3d
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x052d2c9385ca047595afdf1ab0b5b60413a3e001fed98b4af07837560b9cf030
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x062761c952a086471b8f4831bd06afa7a947fa1bd4d0e265d3958b876904a65d
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x003a68b66c44727d8c4e9b7a69c635543dca8237192bfd451d4ce6ab6453090d
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x029c339266a9ad35d5cc64c23bf13b7156e72c27b7df743661537a98af8260b3
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0033a3686a8cd4deb837414ab725db663571a82ae9cb7e28f5df793be32cfd9b
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x059df66af2e0e350842b11ea6b5a903b94640c4ff0418b04ccedcc320f531a08
                >(),
                count: 2
            },
            DuckHolder {
                address: contract_address_const::<
                    0x02e1b05ca7aa24f74a5407c3cdccc9e3f3ad537d0b12c95929694022fff76c60
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0247d79a5a838da63429131f91cd08ea6546aeccd92d3ac004b0d42924417604
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x044c1e43c72dc5ee5bf6885a8a26bf8d1ab69394878e84b27e3f9fe5f9ee592f
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x060853bc9c8ec8fbbc44c715d9adcd19ccb69b8a5d9436875aa2f10e37ba6e9e
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x02c8ac3ed4ed675df1148b065cb535b1b2267d59b33206d1158316a8d7013797
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0062f58625cdb846e467e50e7a613596e45cc04d364ffef8d2429b587a1ebbdd
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x02f65e03646b894465faabff65da01f8e9b13a01b9520d2736412c86825a963c
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x00dae00fc91eb45a0057b759ac3a53a85673c5b5811f9661df9951aa5730e62f
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01bb31a7a78d9a9d413acb94f9d741086562bd8e06368f0b8ef15d874842a772
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x033417cebe9a5c6ec79225bdd2b2a8c85a1e5c655a3ece9df8a0a4b82ba5181b
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x05e5a737d27d100531a80ff805d037892e693476eabb023e8325666faad2418d
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0583ff9d07831006a6f2d55903d57556a538ba626e09e32b7446e46ea75bcf17
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x074fcbb1006e5a0fb043d6ed72759983dd050d914f5c4ce86c4794a132ad75cc
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01d6e3b4be6d503185bee4ea7be853adc24fd6cd12c0a25010e0aec491e6218c
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x03d87ee70baf292cdc23c654153cfd711ff580a076d1dccc0dfd9d3eb62df311
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x04592bf37f51229109ddf190f33750ea1267de436a171b94503a945797e962e6
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x03ba53f9054848b2d45ee9f126c68c0cf168f9cf2064d25cde1241b0d4afeb9e
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x06ae3e526c67a3f38393034abac34e8274a5683c2c4f00d6aefea98057dae5af
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0074e085ba86f8af2fda6f9b6975b668956ca9aff5042abf4859414d4b58691e
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0397a5755efb3bc972e268d36bb204b976ea9515436da96c8e249149db44d903
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x05ac0590c1e6ca7003a092027cf6b829f1dd8b64f33e61e2bf8a7b84f8364ad6
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x076f37f7296806cb2469ec3b8164d7c7d07124a033f9b258c4fd26bc672c5870
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x03f60afe30844f556ac1c674678ac4447840b1c6c26854a2df6a8a3d2c015610
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x03a72a0aedd972966d9bc8a83ec76d792120bdf2d4c1400b0517ca89687ece74
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0583a9d956d65628f806386ab5b12dccd74236a3c6b930ded9cf3c54efc722a1
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0187e6e889b98847171604c360e000295767ab97d458f3e30bb6382ddc9ab232
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x064d59a7ed40c070b848a34fa99c8b85e0ad5e20d291f27eb65a95852dbb3343
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x05f29fa0015b56588f537b393d1d7adf42f7fded1b381e1362dbc765abc29d45
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x00579ed214135f8ed807110d417e47171bdbf9f2c82823361e85428e05f00498
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0100bbcdc4d1232a0454339b8c4e945488348fa44160aa35d05853c67862da9c
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x06499b0f03a71d4560656ec151819961414816622ffb869d3e41b5253afb91f2
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x03ca7173f5d779cf420715ebd13686076542f097e0804defabde275f3e802574
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x02196f613968f65601ece5ebc55c90fbdb7c89dee19009de7e67c62ae09a9483
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x076e9ab09fd50222d6bb29ecb4555ffcbdf9aee81774779f26734483ec1aad43
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0716e39b21fe7062421cb0056e1e3323ded9e9154915c0e89f1c9dff206ba459
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x054f109173319c3596ba693a1b72ca6398477a54c04ed90df0cd53736ff01835
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x010aec0d7974e164c158a942e4b0c1e40bda45d8da04dba8441c2145f9b6d35f
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x061522e92a5ac3250a5a04ce1e849c5cf54d0575257084d1076098732bc44962
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0392227950be49083ecc3e9049a1996127334530bc61d8b6977e589d2f522f9a
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x02311eec8338dac3c9ddb770b7beb8a4642866068286edcc524935e5cb7e02bc
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0365150cb6b6dd1b0a558ad9293a766b2ee7d0f35c3013a864f63a82e78d3464
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x05bd8ab4d952836ca627116bad96ab584480c15e94f9802aea5872d1204c0660
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x00724f832e3e2379c2f0e264eebcf89a07330660b501fd97e39f22d0df018a72
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x028bd296812fcf665a0e6f97c409328dcb035d041146399b323149a0fddf863f
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x03291ce7703250b0705a1b1f38dd45fb686e1f4b165bd4e48b2b3f7c27009bb9
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0097088063de5936c68ddf64fa96676e3df0d8b293cbe61cc0c6dc8c9b729ad1
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0745fc3081d4e195e41c6c44fcb6a56d28d9d2fa683101cb2bc820bbeb7f91fd
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x035b4b6a44c0709c0e8a85abc24a83167320b5a81b4d7c7846c9057e48c64cb7
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x06e35458025a6b6e9463f6877a85538210ccbc66aafe11e2ed5b75152ff1c894
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x04ea404d015c664b683598db155c371dbfa0690a34ac1a49784fb4ffb00cad68
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x02a3cbc52d3a92030452922280b5463c1a53c8a6c11ecaf61eefd473834879cc
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x008bdba40a51c3c01aa2cd30c96df11415d62a45e8b69c1c5a15e9e1e7ec5053
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x04e8fa25c1c786bb014311ed21cd5c5e0aa0b44a276fa6c6775f26febaaed2fb
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x02e1b826ddb432c0021484b5a6935492de4fc06f4caa712a96f75fb650b4695e
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0249cb3b02aab4f0e97f8f5ca7f022890725467a13489e467592a6d58788aec5
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x07d6e5944be389dbe954c359b793616c19aeb01c4b122bed01a6b0bd50e6ae10
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x001056e596acd31aafe85718ee0b73e23a8b69f664eaa49cbf1db421d034851e
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01664a52471912190abf4aae3891bd00cd2b6a75deff4c47f5e006f4063476f8
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x06d1b40ae61ee3c2e794b9a5ff209d91c48e11618151260151b83813f3895faf
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x07b0b6c37ec0c42e1bd8b32b13a880eb87e0bf8304f3afa6cb8b920446ceebdb
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x001bff7d042c65a30a3b83c784082414f849320664c126f195ba712a0dc1b48d
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01f18c123557471766d62232faba31e08ef9fffa053f16ad63c87c4dd82c3b5a
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x00beaacbb054a636e3e83a40438ac34b1bdbb84e999e6741eb715cfe2a96f5dd
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0364dff845db808ee342630b4ff76d3d36e0fcaf16bcdb5cf61b28973101efe1
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01d23a117c058101b7824a36eb27a314f7e47356bf3620c98b64ee93831f75b3
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0039208c58d6b98799a51c1a8a12efd37a6444be4faa562f151a6e593381696e
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01d5be7776ed5d43da2da7de628d9cfe1a9be5356b23870069b898165f980a50
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x039343979e172502e06bd10ace5a3bf2643dde6d4efba68e3b4bca7b313b7351
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0613c2de1f975124d599625a5de0796667bbdb049cd93a3b37a38ab6ef6fdf4a
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x037f66098db2f983d187fb1de48ee23dc418bac882cc89042225562f61dbd15d
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x05819601b6f2c619edb3a4e9703bea4a96a2cb56d7b9dd71cb4f8d85abc0926c
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0325724b1cadc2f4b115b03a0db9d04909d2c9843a85baa7f8db9fe80e241726
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x07e5b021867b78053c4cf51be65fe7146a73be2c3e41f8219ea5bb6c5efd819f
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x03408bc8bb4a935d1216a0f09349f55ea1ee76b8c482905f63c09c6070c5db99
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x030e595670dce495b1c229f71f1fb325954ca6f46e69b89889354b4e40c24857
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x07f828d43ebe7ad71bd526a0ce9372ea55f064551c417db115720c79d2de0828
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x07234bbe8561db8724b4fb0207df3c07b9b9a7540f06db833e6c0a1c3a2e20dc
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x06ff3d1a6cd7537bc0a22c2342d8443816de2fd5869c52e6971815d1f8d68083
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x04f8e28d40424f12efa1adb3a2deb84042eef160ae3e70e396da92f08c3bcece
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01be391c72871ae79a62c33d383576b3c6a9df613c1a4355c79681977aefff40
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01ac519950fe43b010547c9ee01aa5d20e304e86244e18eab45605d4cfb0fb2e
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x003290f9671856621e99f9666063f0057c99d11ffe20c14d2bba26cdb1e0152f
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x06bebd19f50f5e67fb6ddbd8d80c847bb5c9960767e94ed65fc664ae2087e98b
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01283b062455cd91d1be75209a45de8ae022f8756d87fb15ed167de4b69566ca
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0035dd8e05a39fb93ae3508049d0d6b171be67a9d6f633c1b67acbb291032a78
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0377d340cf5bf9c68dbc31d3a29bce45214eb23607ff94cd3d5e57bca6a98483
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x074ebab5d75e059545c489da89151693ccddd621cdaadf8410f9d0667297a78c
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01028cb54b6a7dcf8d12bfe8aa0dfbe7a98d9c34bfacc71220193b62610f7623
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x066146a7433c0c258029e436efc3b63cd8b2bc461709b1b7f1678710c51bf433
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0549c4f75c33cbfc751633ef3d9864577649d573ce1b3333c59b1b8f585417a7
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x052006fb55cc68923f93e20df1800581feba54d98ba5a5fe60754ca9519d0e15
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x04c83d3fa770187d7b0a23b3aa7132c7c8273fb4ec3db416f86e4a385596769a
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x03481232986c183712a948e08664978d74ebb0ef389bc2c9de6501bad1f82010
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x047534b406f5cc20e891aeafa092a4af6485c27667af210e42dfeab9625ac953
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x02180ef36d0e7c54d971df63952ca6f4e5c4355ff6ad6c6c2c6b94dcb5320e0e
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x016ed9a05015ae6a845a3c900b87267ee418d5e2507150d8a993404dc722a95a
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0724102a5654d669ba7ce25e420e733ddb409b753598ab0883ad476cf9faed7b
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x056810f30ad4992a9bcfd52b30f4dfbf3fa6e2b44c8d43b6ca6d89aa7e35e7e9
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x043b0701e1a6f1735703df4efcd7af0bc74646bb2e397d44bc52d2c0f51fd8a1
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x06f8959f3b6cace66a7f4a8e45dc9ce246683afb94862c307f2918d5c724c798
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0470f309911955fc04fd9c0119991ab7cd9715ff7e8763993336b7c65a5ae638
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x02e03baacb2bb218b9f7860e9e3af6fbefa6a9c6efff767936961fe39a9dd91d
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0056e37435d9fb1c013ccff246d1a3eda13220f9c3f81ab4c2ad773e736c047e
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0766c80f0e7cc6ac9c08257a7edd0222908394af2e834b5324719ec46fa05c75
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x03ed54215ce17fbcbb40cb45dd79971e3a97d54cee9be73709d47de9bd2089fe
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x06e5d654abe979c3deff52be6df4416352c12ee21428d5b2cf91ca440c4edbd0
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01e15b5efef75cabb240ef998c66e8a3149323e18775a8ce71242a617c54dc7f
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x061b6c0a78f9edf13cea17b50719f3344533fadd470b8cb29c2b4318014f52d3
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x036df1c5492c19ea7575f4360e939714d240d92fea73f06d87c5de4e43505600
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01d4b406fb86ec21f961498762c02846016e94bf33d27c431c1ddfd96c5617b5
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0050f4d07896d18800667cf154b596322b6c0b804e984797e7e1b8910ebb7fdc
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x00362853a80f580d9b89259e1f768bfcfbb5e9f8867fa1ed9e2b101434c5c88e
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x02e77b727c4ee763d5d9fba1fe187412015b5668af313d7880cb86434e247197
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x015f7b46e0a4eba13a3ecf43ef89c7456bc6c2479c153c45c9d7f2a6107daf90
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0742bf0f23267eb61ad39de32cb34316fe0ef00981c5aab0da5e251383ce039b
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x00a713449621a87918438c335880a49681413a86a679dda44a6f184b08b24f4f
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01c2e8da095223bd039ec1124ff584cf6fa03207952cccf7443d3c8da1868c5a
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0718297c0325f9bcc741c0a9ea4ffdaf6da39dffcdd3942010209f64f2dcd0c2
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x056011ee05283b8c01a4f274dc447e0aca07aa4ced996c0de9acb8430129350f
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x06d9830d946347b772bfe97992e1d030dc30a40579ce3ae0b82bec432697bfa1
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x029b96adaefdb4299be95cdee599bff6bcca26c4e85a4d8ace79231f4618017f
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x003b1b63fff539be8731edb0e65dd2c887c71adcd6cfc6c9d9023570ace7143a
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0729aa5d4d0daaf1e867ad2ce3108ef3f3439a64545eff7ccd18606f92ab1f12
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0412cd365154ae0fa051ad3fafafbaa0231e3e5022eae7904cae33484f88d14a
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x03aa3732ba41ad16733fc0db1ac682b84bda2739dcce19229e97b8094604bff8
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01ebef66c5284b34f2a400fb0137b8d25c29f98e2499535228df1c899e2d3249
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0067f1324966df0de4bcf65ffe8e08a9a0877af77e321b8cac0847d0dfb18529
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x00dbfad4931f04597b4034c2ce5da7b62d197249e0094c1d5852adeea0cfcddb
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x07d26980311893f16b5f5b93cc2aa372ce34944e9efa2c43d47b3d8a4287b386
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0270d7da66631e26b882c987d25743738fb50947bddeadd7b4fb56a04dcd35ed
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0004b6767aea46adba81b673177c30dcad9cfc719aaf6487c03f8319389a1548
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x052119c345e6c7ef3997b3b2f3c01323afc4bd9bc75aa20e4cb73a8443848b1a
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x00fa26159c3b46d019567fa46feaa35fb04ebd2102ba9fbe2813cc50f6849026
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0379de2efcfcbabe0cf373bf5b7d951bb28ff794fa32aae69ddaa77a0d6ed1ad
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x016d3fd2048e2c0865169ec26a4419388a56adb11b600eb7f8ab4dda86a9bd70
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x07a096ecaa08a3a50dc2e1283c38586c497e0e684648ab2abe02427e2afe1e77
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x06096cc5690987a441745a12ccdd9a8453b49ee7187296630c62e6b5c50377f4
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x055b9a935f4325e413ae995bebbed5998e375056f74f997c3ea75d12af43abcd
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x062513b05f2d77687ecdca05805afc5b580bb951cc2fedee69ec64a6ab87fb50
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0245e8b6171b3f453bd13997d600c0652ad675a9265e49249a6c333a3796be4b
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0720eba8edea43289347d8cc5518a1944b3eb5c9bde8f255c4946f9ff21d782d
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x042b140d86e07cb75569c7bd6e9cb1447c78a3940d9d19a3fbd9f378bc1862f4
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x07286557f5976f50e3c1c8ae72843ca29db89b5c2b3fa1f5d0dbaf3c63b30545
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x04cef9e8d06eafce97b2da7057f77860fe2e7942c6df23f6f0e45f293cca2ef0
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x018609026d235698aa871eb1e1485c1cb5904f4a0c363ad5b7f83874aea4b6b1
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x07d750599f4bcfcee9fcf17159ee14d0751afc02aa35bd71aa16298662b614e1
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x00313a3a9c0619b79da6f793b9f0217062dfca376d6904ce60682bb73c1e650e
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x04cda5884a3a4c89261dff18b14dd8e4a4a7038d9f8bffe14b744e6e3ecd57b7
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x0603bd87e21febc7abbbd518f8ee4a2c7e00b5280afada7b582b1e20e66648db
                >(),
                count: 1
            },
            DuckHolder {
                address: contract_address_const::<
                    0x01e64eabc1aab7b548d03f0d6e54e2e1f99989f5e249af3d06bd607c32cceb75
                >(),
                count: 1
            }
        ]
            .span()
    }
}

#[starknet::interface]
pub trait IERC721Mixin<TState> {
    fn balance_of(self: @TState, account: ContractAddress) -> u256;

    fn owner_of(self: @TState, token_id: u256) -> ContractAddress;

    fn safe_transfer_from(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );

    fn transfer_from(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256);

    fn approve(ref self: TState, to: ContractAddress, token_id: u256);

    fn set_approval_for_all(ref self: TState, operator: ContractAddress, approved: bool);

    fn get_approved(self: @TState, token_id: u256) -> ContractAddress;

    fn is_approved_for_all(
        self: @TState, owner: ContractAddress, operator: ContractAddress
    ) -> bool;

    // IERC721Metadata
    fn name(self: @TState) -> ByteArray;

    fn symbol(self: @TState) -> ByteArray;

    fn token_uri(self: @TState, token_id: u256) -> ByteArray;

    // IERC721CamelOnly
    fn balanceOf(self: @TState, account: ContractAddress) -> u256;

    fn ownerOf(self: @TState, tokenId: u256) -> ContractAddress;

    fn safeTransferFrom(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        tokenId: u256,
        data: Span<felt252>
    );

    fn transferFrom(ref self: TState, from: ContractAddress, to: ContractAddress, tokenId: u256);

    fn setApprovalForAll(ref self: TState, operator: ContractAddress, approved: bool);

    fn getApproved(self: @TState, tokenId: u256) -> ContractAddress;

    fn isApprovedForAll(self: @TState, owner: ContractAddress, operator: ContractAddress) -> bool;

    // IERC721MetadataCamelOnly
    fn tokenURI(self: @TState, tokenId: u256) -> ByteArray;

    // ISRC5
    fn supports_interface(self: @TState, interface_id: felt252) -> bool;
    fn supportsInterface(self: @TState, interfaceId: felt252) -> bool;
}