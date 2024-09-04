use core::starknet::ContractAddress;

#[starknet::contract]
mod Syndicate {
    use super::{IERC721Mixin, ILootSurvivor, ILootSurvivorDispatcher, ILootSurvivorDispatcherTrait};
    use core::num::traits::Zero;

    use core::starknet::{
        ContractAddress, contract_address_const, storage::{Map}, get_contract_address,
        get_caller_address
    };
    use openzeppelin_token::erc721::erc721::ERC721Component::InternalTrait;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use openzeppelin_introspection::src5::SRC5Component;
    use syndicate::renderer::create_metadata;


    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    impl SRC5 = SRC5Component::SRC5Impl<ContractState>;
    impl ERC721 = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721Metadata = ERC721Component::ERC721MetadataImpl<ContractState>;
    impl ERC721CamelOnly = ERC721Component::ERC721CamelOnlyImpl<ContractState>;
    impl ERC721MetadataCamelOnly = ERC721Component::ERC721MetadataCamelOnlyImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        _collectionTokenEndIndex: Map::<u8, u16>,
        _deployer_address: ContractAddress,
        _isCollectionAirdropped: Map::<u8, bool>,
        _loot_survivor_dispatcher: ILootSurvivorDispatcher,
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
        self.erc721.initializer("The Syndicate", "SYN", "");
        self._deployer_address.write(get_caller_address());
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
            self.erc721._require_owned(token_id);

            let mut community_id: u8 = 0;
            if (token_id.try_into().unwrap() < self._collectionTokenEndIndex.read(1)) {
                community_id = 1;
            } else if (token_id.try_into().unwrap() < self._collectionTokenEndIndex.read(2)) {
                community_id = 2;
            } else if (token_id.try_into().unwrap() < self._collectionTokenEndIndex.read(3)) {
                community_id = 3;
            } else if (token_id.try_into().unwrap() < self._collectionTokenEndIndex.read(4)) {
                community_id = 4;
            } else if (token_id.try_into().unwrap() < self._collectionTokenEndIndex.read(5)) {
                community_id = 5;
            } else if (token_id.try_into().unwrap() < self._collectionTokenEndIndex.read(6)) {
                community_id = 6;
            } else if (token_id.try_into().unwrap() < self._collectionTokenEndIndex.read(7)) {
                community_id = 7;
            } else if (token_id.try_into().unwrap() < self._collectionTokenEndIndex.read(8)) {
                community_id = 8;
            } else {
                community_id = 9;
            }

            //
            // check if Syndicate won the LS launch tournament
            let mut syndicate_won_tournament = false;
            let loot_survivor_dispatcher = self._loot_survivor_dispatcher.read();
            if loot_survivor_dispatcher.contract_address.is_non_zero() {
                let launch_tournament_winner = loot_survivor_dispatcher
                    .get_launch_tournament_winner();
                syndicate_won_tournament = launch_tournament_winner == get_contract_address();
            }

            create_metadata(token_id.try_into().unwrap(), community_id, syndicate_won_tournament)
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

        fn airdrop_dojo(ref self: ContractState) -> u16 {
            _airdrop_dojo(ref self)
        }

        fn airdrop_starkware(ref self: ContractState) -> u16 {
            _airdrop_starkware(ref self)
        }

        fn airdrop_argent(ref self: ContractState) -> u16 {
            _airdrop_argent(ref self)
        }

        fn airdrop_dope_wars(ref self: ContractState) -> u16 {
            _airdrop_dope_wars(ref self)
        }

        fn airdrop_1337(ref self: ContractState) -> u16 {
            _airdrop_1337(ref self)
        }

        fn airdrop_stark_id(ref self: ContractState) -> u16 {
            _airdrop_stark_id(ref self)
        }

        fn airdrop_defi_spring(ref self: ContractState) -> u16 {
            _airdrop_defi_spring(ref self)
        }

        fn airdrop_golden_token(ref self: ContractState) -> u16 {
            _airdrop_golden_token(ref self)
        }

        fn airdrop_loot(ref self: ContractState) -> u16 {
            _airdrop_loot(ref self)
        }
        fn set_loot_survivor_address(ref self: ContractState, address: ContractAddress) {
            // only deployer can set loot survivor address
            assert(get_caller_address() == self._deployer_address.read(), 'Not authorized');

            // address can only be set once
            assert(
                self._loot_survivor_dispatcher.read().contract_address.is_zero(),
                'LS address already set'
            );

            // address cannot be zero
            assert(address.is_non_zero(), 'LS address cannot be zero');

            // store dispatcher
            let dispatcher = ILootSurvivorDispatcher { contract_address: address };
            self._loot_survivor_dispatcher.write(dispatcher);
        }
    }

    fn _assert_token_not_airdropped(self: @ContractState, communityId: u8) {
        assert(
            self._isCollectionAirdropped.read(communityId) == false, 'Collection already airdropped'
        );
    }

    fn _assert_token_airdropped(self: @ContractState, communityId: u8) {
        assert(self._isCollectionAirdropped.read(communityId) == true, 'Not ready for airdrop');
    }

    fn _airdrop_dojo(ref self: ContractState) -> u16 {
        _assert_token_not_airdropped(@self, 1);
        let mut token_count: u16 = 1;

        let mut addresses = get_dojo_addresses();
        let num_mints = 6;
        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    let mut mint_count = 0;
                    loop {
                        if mint_count == num_mints {
                            break;
                        }
                        self.erc721.mint(*address, token_count.into());
                        token_count += 1;
                        mint_count += 1;
                    }
                },
                Option::None(_) => { break; }
            };
        };

        self._collectionTokenEndIndex.write(1, token_count);
        self._isCollectionAirdropped.write(1, true);
        token_count
    }

    fn _airdrop_starkware(ref self: ContractState) -> u16 {
        _assert_token_not_airdropped(@self, 2);
        _assert_token_airdropped(@self, 1);
        let mut token_count: u16 = self._collectionTokenEndIndex.read(1);

        let mut addresses = get_starkware_addresses();
        let num_mints = 6;
        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    let mut mint_count = 0;
                    loop {
                        if mint_count == num_mints {
                            break;
                        }
                        self.erc721.mint(*address, token_count.into());
                        token_count += 1;
                        mint_count += 1;
                    }
                },
                Option::None(_) => { break; }
            };
        };
        self._collectionTokenEndIndex.write(2, token_count);
        self._isCollectionAirdropped.write(2, true);

        token_count
    }

    fn _airdrop_argent(ref self: ContractState) -> u16 {
        _assert_token_not_airdropped(@self, 3);
        _assert_token_airdropped(@self, 2);
        let mut token_count: u16 = self._collectionTokenEndIndex.read(2);

        let mut addresses = get_argent_addresses();
        let num_mints = 4;
        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    let mut mint_count = 0;
                    loop {
                        if mint_count == num_mints {
                            break;
                        }
                        self.erc721.mint(*address, token_count.into());
                        token_count += 1;
                        mint_count += 1;
                    }
                },
                Option::None(_) => { break; }
            };
        };

        self._collectionTokenEndIndex.write(3, token_count);
        self._isCollectionAirdropped.write(3, true);

        token_count
    }

    fn _airdrop_dope_wars(ref self: ContractState) -> u16 {
        _assert_token_not_airdropped(@self, 4);
        _assert_token_airdropped(@self, 3);
        let mut token_count: u16 = self._collectionTokenEndIndex.read(3);

        let mut addresses = get_dope_wars_addresses();
        let num_mints = 5;
        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    let mut mint_count = 0;
                    loop {
                        if mint_count == num_mints {
                            break;
                        }
                        self.erc721.mint(*address, token_count.into());
                        token_count += 1;
                        mint_count += 1;
                    }
                },
                Option::None(_) => { break; }
            };
        };

        self._collectionTokenEndIndex.write(4, token_count);
        self._isCollectionAirdropped.write(4, true);

        token_count
    }

    fn _airdrop_1337(ref self: ContractState) -> u16 {
        _assert_token_not_airdropped(@self, 5);
        _assert_token_airdropped(@self, 4);
        let mut token_count: u16 = self._collectionTokenEndIndex.read(4);

        let mut addresses = get_1337_addresses();
        let num_mints = 6;
        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    let mut mint_count = 0;
                    loop {
                        if mint_count == num_mints {
                            break;
                        }
                        self.erc721.mint(*address, token_count.into());
                        token_count += 1;
                        mint_count += 1;
                    }
                },
                Option::None(_) => { break; }
            };
        };

        self._collectionTokenEndIndex.write(5, token_count);
        self._isCollectionAirdropped.write(5, true);

        token_count
    }

    fn _airdrop_stark_id(ref self: ContractState) -> u16 {
        _assert_token_not_airdropped(@self, 6);
        _assert_token_airdropped(@self, 5);
        let mut token_count: u16 = self._collectionTokenEndIndex.read(5);

        let mut addresses = get_stark_id_addresses();

        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    self.erc721.mint(*address, token_count.into());
                    token_count += 1;
                },
                Option::None(_) => { break; }
            };
        };
        self._collectionTokenEndIndex.write(6, token_count);
        self._isCollectionAirdropped.write(6, true);

        token_count
    }

    fn _airdrop_defi_spring(ref self: ContractState) -> u16 {
        _assert_token_not_airdropped(@self, 7);
        _assert_token_airdropped(@self, 6);
        let mut token_count: u16 = self._collectionTokenEndIndex.read(6);

        let mut addresses = get_defi_spring_addresses();
        let num_mints = 5;
        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    let mut mint_count = 0;
                    loop {
                        if mint_count == num_mints {
                            break;
                        }
                        self.erc721.mint(*address, token_count.into());
                        token_count += 1;
                        mint_count += 1;
                    }
                },
                Option::None(_) => { break; }
            };
        };

        self._collectionTokenEndIndex.write(7, token_count);
        self._isCollectionAirdropped.write(7, true);

        token_count
    }

    fn _airdrop_golden_token(ref self: ContractState) -> u16 {
        _assert_token_not_airdropped(@self, 8);
        _assert_token_airdropped(@self, 7);
        let mut token_count: u16 = self._collectionTokenEndIndex.read(7);

        let mut addresses = get_golden_token_addresses();
        let num_mints = 2;

        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    let mut mint_count = 0;
                    loop {
                        if mint_count == num_mints {
                            break;
                        }
                        self.erc721.mint(*address, token_count.into());
                        token_count += 1;
                        mint_count += 1;
                    }
                },
                Option::None(_) => { break; }
            };
        };

        self._collectionTokenEndIndex.write(8, token_count);
        self._isCollectionAirdropped.write(8, true);

        token_count
    }

    fn _airdrop_loot(ref self: ContractState) -> u16 {
        _assert_token_not_airdropped(@self, 9);
        _assert_token_airdropped(@self, 8);
        let mut token_count: u16 = self._collectionTokenEndIndex.read(8);

        let mut addresses = get_loot_addresses();
        let num_mints = 7;

        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    let mut mint_count = 0;
                    loop {
                        if mint_count == num_mints {
                            break;
                        }
                        self.erc721.mint(*address, token_count.into());
                        token_count += 1;
                        mint_count += 1;
                    }
                },
                Option::None(_) => { break; }
            };
        };
        // we have four remaining NFTs to complete set of 1600, manually minting them to LH and DD
        // as part of the Loot syndicate
        self
            .erc721
            .mint(
                contract_address_const::<
                    0x02dD93bcFc6DcB21083f9E045066c54A45e0AEFB00a6C79eB5286eE0e1801504
                >(),
                token_count.into()
            );

        token_count += 1;
        self
            .erc721
            .mint(
                contract_address_const::<
                    0x02dD93bcFc6DcB21083f9E045066c54A45e0AEFB00a6C79eB5286eE0e1801504
                >(),
                token_count.into()
            );
        token_count += 1;
        self
            .erc721
            .mint(
                contract_address_const::<
                    0x065d2AB17338b5AffdEbAF95E2D79834B5f30Bac596fF55563c62C3c98700150
                >(),
                token_count.into()
            );
        token_count += 1;
        self
            .erc721
            .mint(
                contract_address_const::<
                    0x065d2AB17338b5AffdEbAF95E2D79834B5f30Bac596fF55563c62C3c98700150
                >(),
                token_count.into()
            );
        token_count += 1;

        self._collectionTokenEndIndex.write(9, token_count);
        self._isCollectionAirdropped.write(9, true);

        token_count
    }

    #[inline(always)]
    pub fn get_dojo_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x02c3F466e4e8C0255ff52ade0E4fC7E8024CCd8c530e58FB888C2d0D7BcF11B6
            >(),
            contract_address_const::<
                0x03C63FFBBB09b7E7D74F85e95c85255829Ad79b59E3D63Cb66E635c12fFAf08b
            >(),
            contract_address_const::<
                0x064fd0b4e9b1e0d61a13d431f59ddfeaa49fcd4f48aad799b5dfd5fedb45e77c
            >(),
            contract_address_const::<
                0x02Bc9bbD6aBdFc745918827D9438052d854F079F3Dd91739B45dfbe5B0f54B5C
            >(),
            contract_address_const::<
                0x069213226154069d250944a7CC15140BC45039924b9BbCda7Be4F15227654eC6
            >(),
            contract_address_const::<
                0x04e1E065942E03C1BaF4EBFF3563cee4230c83c3e53598800b8553FB3348b421
            >(),
            contract_address_const::<
                0x008b0aC0621b55aaa1E7F568C4CE66C3D078dd37849eE3a8d366bd89e0439a86
            >(),
            contract_address_const::<
                0x02CD97240DB3f679De98A729aE91EB996cAb9Fd92a9A578Df11a72F49bE1c356
            >(),
            contract_address_const::<
                0x04645f67e3e195420b2b4e63742153623e50c143ed8b89c91e3fb908fe87b168
            >(),
            contract_address_const::<
                0x04042b3F651F6d6Ff03b929437AdC30257333723970071b05cb0E2270C9dc385
            >(),
            contract_address_const::<
                0x065d2AB17338b5AffdEbAF95E2D79834B5f30Bac596fF55563c62C3c98700150
            >(),
            contract_address_const::<
                0x02dD93bcFc6DcB21083f9E045066c54A45e0AEFB00a6C79eB5286eE0e1801504
            >(),
            contract_address_const::<
                0x0013588bbA0f78e623497f52702ca3ECF420fc82c032182473DB95b9DC0bFe33
            >(),
            contract_address_const::<
                0x058E058Cc515404046B9A125531b92DFB9542B02829447381483520Df7E7E39e
            >(),
            contract_address_const::<
                0x0643948eef68D67CBd9A1853b6181B83f15D06953724Fd5347e922d40245B93C
            >(),
            contract_address_const::<
                0x069213226154069d250944a7CC15140BC45039924b9BbCda7Be4F15227654eC6
            >(),
            contract_address_const::<
                0x0628b9dE919e8d1Cfb31A4e435E0CA27F33a8DC71b7475fD1a122222A6eb2f89
            >(),
            contract_address_const::<
                0x02c3F466e4e8C0255ff52ade0E4fC7E8024CCd8c530e58FB888C2d0D7BcF11B6
            >(),
            contract_address_const::<
                0x0082Ab51630d38aa639599165B08CE9e92208de7A9f4a0b3147bfABE6D3eB763
            >(),
            contract_address_const::<
                0x0291c1dfe2ab9858fadf1000f2c0c14fd197fc56483239dc5e7d4a42be8efe04
            >(),
            contract_address_const::<
                0x03d87EE70baf292Cdc23C654153cFD711fF580a076d1dccc0dfd9D3eb62DF311
            >(),
            contract_address_const::<
                0x064fd0b4e9b1e0d61a13d431f59ddfeaa49fcd4f48aad799b5dfd5fedb45e77c
            >(),
            contract_address_const::<
                0x06F490C0ec49FE17148af6F83eBEBd9d31E5a06dC46BDBE5c5E0657c23A4fF4F
            >(),
            contract_address_const::<
                0x04645f67e3e195420b2b4e63742153623e50c143ed8b89c91e3fb908fe87b168
            >(),
            contract_address_const::<
                0x0695A65AF5F0f019153237122256401e65A15c9B53B86705A0F40CF59f8681BC
            >(),
            contract_address_const::<
                0x02CD97240DB3f679De98A729aE91EB996cAb9Fd92a9A578Df11a72F49bE1c356
            >(),
            contract_address_const::<
                0x02Bc9bbD6aBdFc745918827D9438052d854F079F3Dd91739B45dfbe5B0f54B5C
            >(),
            contract_address_const::<
                0x071538f6445e0c6179b786230a3e7b5ddee40b72673a9b5a395da20f4657bdca
            >(),
            contract_address_const::<
                0x04042b3F651F6d6Ff03b929437AdC30257333723970071b05cb0E2270C9dc385
            >(),
            contract_address_const::<
                0x06a519DCcd7Ed4D1aACD3975691AEEae47bF7f9F5b62Ed7C2D929D2E27A9CC5E
            >(),
            contract_address_const::<
                0x04042b3F651F6d6Ff03b929437AdC30257333723970071b05cb0E2270C9dc385
            >(),
            contract_address_const::<
                0x06a519DCcd7Ed4D1aACD3975691AEEae47bF7f9F5b62Ed7C2D929D2E27A9CC5E
            >(),
            contract_address_const::<
                0x06e493eaf86D4542dc26f11876693b9C330B3921eD47cC91D14A18e66B2e27Dd
            >(),
            contract_address_const::<
                0x01046f05042e6E52a7890a07b1cc2Cd5F49A5e7411D543f9f5A3b5ce1482270A
            >(),
            contract_address_const::<
                0x02c08c7f211df3251ebab406b3fc4dbab93f839bb964a27b125c1496b930f68b
            >(),
            contract_address_const::<
                0x02194978b3f9B9ac05733A646d911e323C95382cd5bECDF90bad2477e4832DFD
            >(),
            contract_address_const::<
                0x02e2e9920949f5583ae11376d76315df059c8650779bf983aab80669b15ce265
            >(),
            contract_address_const::<
                0x01Dd39a78344e6B296c79B8fD06B479F95740070E6B0a2F1D22d00f2E54A72Ba
            >(),
            contract_address_const::<
                0x0082Ab51630d38aa639599165B08CE9e92208de7A9f4a0b3147bfABE6D3eB763
            >(),
            contract_address_const::<
                0x045A8475062f6c0D19dDAe10502197B77b896aaeEdd3ED3aB10FB0d9Bd0B4aC0
            >(),
            contract_address_const::<
                0x0269cb810bc22316f8e6a53d164398e83f8255f7e980621f6083e5f7bad74fa0
            >(),
            contract_address_const::<
                0x04042b3F651F6d6Ff03b929437AdC30257333723970071b05cb0E2270C9dc385
            >(),
            contract_address_const::<
                0x05c8Ec0993aFC0D6b928f0c41521bE62708BaCabd3E3bAA988b2DCaaB1aEd801
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_starkware_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x02C71De70B40b00e3dD6F43eD568bF4B194FaB0189DF68C54D25CBbb9b9e3D49
            >(),
            contract_address_const::<
                0x034325479E4Ce970fEb1129F0890683F2cFb1A28Be2516450fc110b38C075170
            >(),
            contract_address_const::<
                0x05f4bb7eb0d99786214779746922fb4d139404507069129c19af051ee324fd48
            >(),
            contract_address_const::<
                0x043a3dd13ea505b6c25000f6d93501b16d244b08aa5795c64022bdfc950b1464
            >(),
            contract_address_const::<
                0x0718505b87b5a448205ae22ac84a21b9e568b532ed95285c4c03973f8b1a73e8
            >(),
            contract_address_const::<
                0x034325479e4ce970feb1129f0890683f2cfb1a28be2516450fc110b38c075170
            >(),
            contract_address_const::<
                0x0378B9c3cb6be32d087D1af8A91C1484226AC8b009F502E12B06FFD46D94F014
            >(),
            contract_address_const::<
                0x064A83EecB44F67F106469F75987a73f7edE081DA11179fED27bFBf449cD6861
            >(),
            contract_address_const::<
                0x02e8f4fd003b2376d2bc7a6f9a38e8f46000db6e5f6520073c297e76fa696fdc
            >(),
            contract_address_const::<
                0x00D20769F788313C84DfCE76C37a04BC364Ea0BA0c79FD02ad8C61271626996e
            >(),
            contract_address_const::<
                0x07650ed18de65ab80c9e055f453d96f45d1a2e512b8bacb69e739d67c88c1f96
            >(),
            contract_address_const::<
                0x04FDbFdfae3661Ea118167b34B0C91594342B5Cc522824a704ADB4dB86F86a31
            >(),
            contract_address_const::<
                0x022AbBc2808356e8303c0704EB4204De03Ee3d50fee9bE2895c7757a80616B63
            >(),
            contract_address_const::<
                0x01bf7710eaf808c0b05cf43288566222e370768ad9847c264b2cb9a1d6b5b41c
            >(),
            contract_address_const::<
                0x0749965A6A085688977B5E940ee9198b043610FcEA78B17f397C666A232d0529
            >(),
            contract_address_const::<
                0x06a01275390af949f5b3732f9620e42785e00a63e3113d80b2c8ec07c463c870
            >(),
            contract_address_const::<
                0x050ed5ff1d8cc5815b414ddc4bcb268bab4dc3971deed6014ea19ea1547909ac
            >(),
            contract_address_const::<
                0x06e01D4E101aD2F8DAAedDAC7d11aE85CABe0F79d5A6C16b15b92c10975a40b1
            >(),
            contract_address_const::<
                0x00f39aa3ceb7b253c7a39c79cf6a521182e8d97a51aa82d77e7caac4aa359918
            >(),
            contract_address_const::<
                0x06496c659adab5aeeb34d7767f697ad41abfec046584313fe54fc304804fb195
            >(),
            contract_address_const::<
                0x01bd320BcCf541F9926c81D16535a37c371c282C87346EEe8Cf23aDa2D07628d
            >(),
            contract_address_const::<
                0x043b0701e1a6f1735703df4efcd7af0bc74646bb2e397d44bc52d2c0f51fd8a1
            >(),
            contract_address_const::<
                0x05852345853c28389363eC23129e5839717AEC56606a085892749B790ee4495b
            >(),
            contract_address_const::<
                0x07d0b1732027a958489e987c85b3bd544d950409912b8c13842150c14e89a7ab
            >(),
            contract_address_const::<
                0x06713fb0a93cc7b37c0ed55fde7387307a38d85323922a0904cbf8dc0bcca838
            >(),
            contract_address_const::<
                0x07af08dad44af4f7461979294f7eff8d3617c27c7c3e3f8222fd2a871517e719
            >(),
            contract_address_const::<
                0x07360aee5743eba462e17e1886cca91be06ad5110fd3142d284332af3fc7248b
            >(),
            contract_address_const::<
                0x046E211282EDbA14eA31CD0B2Ba69612426992235D51A8dA8503743278c4B79D
            >(),
            contract_address_const::<
                0x04a8713ab7aff5e97fb1aa7652314a5ed6102b200da75ef42078a5a01fef4093
            >(),
            contract_address_const::<
                0x01f1f54C2947eefC48dF80169479A991764DC165E1819F55E7371eb9cbBbbc05
            >(),
            contract_address_const::<
                0x07480f307b7c0dc18bfc17ef425f8ad3319b89e1d347897537d9b5fe66b1f7f7
            >(),
            contract_address_const::<
                0x0618b45875fb9f080633064826ca0fcec99c2eacfbf97593bea926e98ed1725a
            >(),
            contract_address_const::<
                0x013910c9d8dda3fa6330416d6003c2382d257e9c22a1c5ffd2f20069d493f9cf
            >(),
            contract_address_const::<
                0x0765f4a71dcf056a422712a2d890b300cb0bec7d317d172703400f4be17d786b
            >(),
            contract_address_const::<
                0x079a588a877981cb44e2db1af881d807470d9bad21ff0a36de370ae6278c6e62
            >(),
            contract_address_const::<
                0x0326223ea8938aa49bfe9e5b114dc52abaa387dd5e6c7ced94883dc9c42b0a2a
            >(),
            contract_address_const::<
                0x05ecCe71581459dCc88a2a10b3237309B78368d4d7218Ed3c69521A7a30cf6e0
            >(),
            contract_address_const::<
                0x02ff9d1ccff043c05753dbf6c2c47be24947ae5ed429843cd8ec7c774454072d
            >(),
            contract_address_const::<
                0x052119c345e6c7ef3997b3b2f3c01323afc4bd9bc75aa20e4cb73a8443848b1a
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_argent_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x008Ef3E993AFaA142818a479D101d8750B392624c452D4505645Ab384f59c07B
            >(),
            contract_address_const::<
                0x075c1C511ae269aCbD9bB383A3C9Cc4b12434AC07a993D0f7Fd284fF58c4DbF1
            >(),
            contract_address_const::<
                0x01979443B17F4d7cC6448B10030d164e823C346fd09AA7F1eC287C85ea1e36ED
            >(),
            contract_address_const::<
                0x009a8cbDbEdEa11F87232eb34A8893aC77893D92051e895F51B1bfd43E4EfAA8
            >(),
            contract_address_const::<
                0x0749965A6A085688977B5E940ee9198b043610FcEA78B17f397C666A232d0529
            >(),
            contract_address_const::<
                0x0724102a5654d669ba7CE25E420e733ddb409B753598AB0883ad476cf9FaEd7b
            >(),
            contract_address_const::<
                0x03413d0e83e07e65ada73d3a837B01C5c9fa26C4E75EF8557d46D96C1D897820
            >(),
            contract_address_const::<
                0x06718063E1b58e50496f808A207EC1ab9D9ecC3DCde11086c172Bff90C9B21bE
            >(),
            contract_address_const::<
                0x032F4986Bf8dA294a0cdb3B3603eCbb5A2121eb303550949b7c5A195Ea29B3D5
            >(),
            contract_address_const::<
                0x01A12323614bed9D9CE665D2d7b6e4Ca1f08b8Ae52D029585d07F82e3f6F01Da
            >(),
            contract_address_const::<
                0x03777B4FfCA717BFe76e668A9F69EC7dcc4f5b6aD3610D50C565e0066B999BCC
            >(),
            contract_address_const::<
                0x06e2C617AB6f9B03cb17D00a78F22aD5c5Eed6221811EF56616fa6094BFa7F9c
            >(),
            contract_address_const::<
                0x050393e851E40DE930AbcD9569d9Df55883B9F2836d4BaE724F126d2258cD292
            >(),
            contract_address_const::<
                0x021e896a50c10950167e2908BFFf558E25087444ad9E6981F400baba880c1733
            >(),
            contract_address_const::<
                0x02cc64f2553c8b3f1acf857a49a54c69497ad5e368cd9d905bb0ca9ba08f4afd
            >(),
            contract_address_const::<
                0x024d5d94071A358e8B0F3f60c3090cF7A7ce06799208a3A5eBe50B90270D8782
            >(),
            contract_address_const::<
                0x03c7c5334536ee84ecf480d558bf91cd1b6017408af4064f5576197a5808a874
            >(),
            contract_address_const::<
                0x0365150Cb6b6dD1b0a558ad9293a766b2eE7d0f35C3013a864F63a82e78d3464
            >(),
            contract_address_const::<
                0x03f178A78E50275b5ee548765C32E64bF1b74AC3ab225380509DCf5834431Cab
            >(),
            contract_address_const::<
                0x07692919eCad0Aae8469FEFf906AEb30d9B291938B65c7259Dd2a42F179507AA
            >(),
            contract_address_const::<
                0x011f5Fc2a92Ac03434A7937fe982f5e5293B65ad438A989c5b78Fb8f04a12016
            >(),
            contract_address_const::<
                0x053fdeD60b2E71f02992085F7af16E217f3f56BC8D45d3675A1251752e1Df7C6
            >(),
            contract_address_const::<
                0x02775831D81d35d30Cd842511331b482E4275Cd1c8a34AE832aDb0D282307AFd
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_dope_wars_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x002E9132c0665C1b9fDc13733E4302503C4e9006F61AEFFA3E58abcd163475E2
            >(),
            contract_address_const::<
                0x02854ce42ba72711266431eca47108c9f6edf9a8db74c10502c357b76367a545
            >(),
            contract_address_const::<
                0x049DFfB64528ffaeC0dED89106dF886D33873A2331e81328ea9628F0f1341331
            >(),
            contract_address_const::<
                0x022DB9B6BD3Bfc4cee282fa517d09f13b77186CF7a0Bf6d04F3CD9d7e6B5d7fA
            >(),
            contract_address_const::<
                0x07Bc9a23c3C8955941f1134092E0A51dd829F670a656FF55d4c2512993878946
            >(),
            contract_address_const::<
                0x0087D324CC10F45248332723Dd8D73690ade39d186f8F0baB2aA5BAc57cd4567
            >(),
            contract_address_const::<
                0x02E59414C6b09aD452D7621A29F17fcB984c868CC627AD395adBACdeC75b5D1C
            >(),
            contract_address_const::<
                0x02ff9d1ccff043c05753dbf6c2c47be24947ae5ed429843cd8ec7c774454072d
            >(),
            contract_address_const::<0x7385962B8ec19ec876956de678B004520481cab5>(),
            contract_address_const::<
                0x0756E95d87571d374B802DC77Ce6A056318769323f25326eb85B8050427Af03e
            >(),
            contract_address_const::<
                0x04042b3F651F6d6Ff03b929437AdC30257333723970071b05cb0E2270C9dc385
            >(),
            contract_address_const::<
                0x00992cedb437F20b57458d845F42428Da4021535992C59678508AaB0E8FE5B8a
            >(),
            contract_address_const::<
                0x01dc8f0c2077757132d16daabc9f9e23336872ac351fd75979f0362dccd1bd49
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_1337_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x01ed5dde8106315bb414185e1d851c0c0c6b4871e2d084e7f3a6ac1657dd3d19
            >(),
            contract_address_const::<
                0x02865052df1c4406a785b93d696781c9e37b1ad770c2cbe3bb4a18e150b3fbb1
            >(),
            contract_address_const::<
                0x0743E5d0e7Deb43057560026935e23d7E2D25503a94BFbae350e50113a926072
            >(),
            contract_address_const::<
                0x03c46ED6BED02E7fb788F78DE53072339A2044F38A6C7E7281a6a1A9989B54E7
            >(),
            contract_address_const::<
                0x001457c01d3A07acA1435B83fdb9b44b2d1Fd283A56b9b9B17e27c1a891Aaf44
            >(),
            contract_address_const::<
                0x012a957a797A8789257Cd8A7c2586f0d20E7FADD7ADB2d6eDCcABd844f7b88B6
            >(),
            contract_address_const::<
                0x038bAd3A5Ab48a510Fef9363d447f3d4b76439986cBa9b7cCCe1a34B154Bd218
            >(),
            contract_address_const::<
                0x044081eA31B076FD7dAf9F66e5405A64Bf3F6384d9FfeA6c6B8C45E5524c60f3
            >(),
            contract_address_const::<
                0x04cd9deB04C83e7317D76eAeBb6E59173D715Fa58Be509B63B3bcE903c4e340B
            >(),
            contract_address_const::<
                0x03eB57327dea69c6F743606bE35C42EA3B17100564736b60ca4195C21653f194
            >(),
            contract_address_const::<
                0x01eDA935Dc126076d78Dc63b7ffD4893E85577ADD180414DCB8D1bb8C8067C22
            >(),
            contract_address_const::<
                0x429148f7ef4c6041d91869adee47c7f14542ecd5ed56cc50895c84c75ac8205
            >(),
            contract_address_const::<
                0x070286B40C43c130BEEf1101a4260C0e7b2A0f29aEf26323D0B9462E39eAB78A
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_stark_id_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x70d63df9b573f86ccd002d78f19b242232f7e108ae8652b7756ff46734d8b35
            >(),
            contract_address_const::<
                0x66146a7433c0c258029e436efc3b63cd8b2bc461709b1b7f1678710c51bf433
            >(),
            contract_address_const::<
                0x34325479e4ce970feb1129f0890683f2cfb1a28be2516450fc110b38c075170
            >(),
            contract_address_const::<
                0x3858f95e136b3ee520b224dbb7f6b1dc954d993fc773b73785ca949733fbd3a
            >(),
            contract_address_const::<
                0x3d87ee70baf292cdc23c654153cfd711ff580a076d1dccc0dfd9d3eb62df311
            >(),
            contract_address_const::<
                0x2dd93bcfc6dcb21083f9e045066c54a45e0aefb00a6c79eb5286ee0e1801504
            >(),
            contract_address_const::<
                0x53b36f0c83047272633c00db0f5db890dd4bec745446dc17dabbc6828e403a2
            >(),
            contract_address_const::<
                0x4c028c91a17bdb030dac30b84daa3136fdba185e4763f35c4363562095a0689
            >(),
            contract_address_const::<
                0x61b6c0a78f9edf13cea17b50719f3344533fadd470b8cb29c2b4318014f52d3
            >(),
            contract_address_const::<
                0x620b2e12fb8d195ce384512d65fbbddbdea26c4610a49f7630282ea7e55077c
            >(),
            contract_address_const::<
                0x378b9c3cb6be32d087d1af8a91c1484226ac8b009f502e12b06ffd46d94f014
            >(),
            contract_address_const::<
                0x2c71de70b40b00e3dd6f43ed568bf4b194fab0189df68c54d25cbbb9b9e3d49
            >(),
            contract_address_const::<
                0x52119c345e6c7ef3997b3b2f3c01323afc4bd9bc75aa20e4cb73a8443848b1a
            >(),
            contract_address_const::<
                0x460f40b56facb566fa3269ccb89d8fe6c1b50e2cecc47c660be59f17d95ce5e
            >(),
            contract_address_const::<
                0x7e17ab90d2abf29b1a2b418567067d7f1ce49602feb29ac11901e35fb965e
            >(),
            contract_address_const::<
                0x179caf1b35202a0a544109cc04caf07a813755d1a15927e025ad874108b0543
            >(),
            contract_address_const::<
                0xd6be762f81bc91502be53c28f2325c03e0b7073f7f3796f8cfc5804863ba3a
            >(),
            contract_address_const::<
                0x1fb62ac54f9fa99e1417f83bcb88485556427397f717ed4e7233bc99be31bff
            >(),
            contract_address_const::<
                0xece2ddb6f35cfd1c8cd4fb3adffc65048b15a43e3111030c44036493260797
            >(),
            contract_address_const::<
                0x2ff9d1ccff043c05753dbf6c2c47be24947ae5ed429843cd8ec7c774454072d
            >(),
            contract_address_const::<
                0x7bae6a7e209cfe5d2f29e84b226f68e9d538d9e36db09f1363120adb6f5d0a9
            >(),
            contract_address_const::<
                0x579ed214135f8ed807110d417e47171bdbf9f2c82823361e85428e05f00498
            >(),
            contract_address_const::<
                0x6500b2b53e341c23d7be329b33ae307044179dbfb5a5d0576aad9ddf0ae4d70
            >(),
            contract_address_const::<
                0x577b5a148a45f7ed608f8755d0ef01bc0e1b9f3ce7d33a521fc401fba13acc6
            >(),
            contract_address_const::<
                0x6fb5e4e650bb6ceb80923c008e81122129092efc7e6d6f3f5c9ac4eead25355
            >(),
            contract_address_const::<
                0x5b2de21befe429642ca311d522035e3990c4433cd3b91cabb3019ceebbd87ed
            >(),
            contract_address_const::<
                0x3d85759add09b3318a002ddc57f81c67286fdde869cbbdaa39ceb17c0661e6f
            >(),
            contract_address_const::<
                0x39b627a7f29423e7cc7df35002c8f3992311b62f880d2f472f2d6e7432e91b9
            >(),
            contract_address_const::<
                0x4fd13c902c6825caf81f059eccea5824d4c84bdc3c6af30696b6f7be5551e2e
            >(),
            contract_address_const::<
                0x6b82a7d520520170c12dcbbaa3c6ea1e8d92c4d5f666da0b53b849f50ba6e34
            >(),
            contract_address_const::<
                0x643948eef68d67cbd9a1853b6181b83f15d06953724fd5347e922d40245b93c
            >(),
            contract_address_const::<
                0x43b0701e1a6f1735703df4efcd7af0bc74646bb2e397d44bc52d2c0f51fd8a1
            >(),
            contract_address_const::<
                0x4645f67e3e195420b2b4e63742153623e50c143ed8b89c91e3fb908fe87b168
            >(),
            contract_address_const::<
                0x74f91d284351a8603933b648684b6a990126d7c78a1b867353a57a3bc2097da
            >(),
            contract_address_const::<
                0x30f5e98e04383d649ee604f09b91e8263d7e4f60b7647e5d4831741aad25e78
            >(),
            contract_address_const::<
                0x121edbee8028cf9ef6c36e823da961c6b2909b51040d0c9cb6f1a4fe4e526ae
            >(),
            contract_address_const::<
                0x4fdbfdfae3661ea118167b34b0c91594342b5cc522824a704adb4db86f86a31
            >(),
            contract_address_const::<
                0x6e01d4e101ad2f8daaeddac7d11ae85cabe0f79d5a6c16b15b92c10975a40b1
            >(),
            contract_address_const::<
                0x65d2ab17338b5affdebaf95e2d79834b5f30bac596ff55563c62c3c98700150
            >(),
            contract_address_const::<
                0x2bc9bbd6abdfc745918827d9438052d854f079f3dd91739b45dfbe5b0f54b5c
            >(),
            contract_address_const::<
                0x628b9de919e8d1cfb31a4e435e0ca27f33a8dc71b7475fd1a122222a6eb2f89
            >(),
            contract_address_const::<
                0x7360aee5743eba462e17e1886cca91be06ad5110fd3142d284332af3fc7248b
            >(),
            contract_address_const::<
                0x438fcf3c887299aeaf6d3ee8ef14626219b7e4eb1f06a0a3a5cbeddb041d1d8
            >(),
            contract_address_const::<
                0x7b86946381b25725ad72eaf5d2cdf9e87e2b98a70980576d212fa7fcc6c9701
            >(),
            contract_address_const::<
                0x5095078578a59f8a9c17df97188db1b59574c6d4836dd3e705fe8537624228a
            >(),
            contract_address_const::<
                0x70512c3a3c5e90a3ef0bed1078ad8ec12bf1085c05f2f10f8413b7879bddfcf
            >(),
            contract_address_const::<
                0x3484e299d480b980c420b895850ee01b1c39011731d1b657ecd6fbf142b6939
            >(),
            contract_address_const::<
                0x708ae8b37a4676ed706e1f2d9840bde788df794aafb57621b9ae1eb2a172c10
            >(),
            contract_address_const::<
                0x6820aad506f7869ce79a5d22a3fe06bc03f53ce4a35db63c7082d2daddcca58
            >(),
            contract_address_const::<
                0x3e7236bb88cc60abe553366ac11aeac445ab57c45269e9f5f0917c7d69ac581
            >(),
            contract_address_const::<
                0x5e1093303fef57563f6ccf3dbd5b3f1c3a5eb31c12e256dcb9066f5ca17f5b4
            >(),
            contract_address_const::<
                0x5e1093303fef57563f6ccf3dbd5b3f1c3a5eb31c12e256dcb9066f5ca17f5b4
            >(),
            contract_address_const::<
                0x120531e840199209ee6fb9ce1d6116cb99a7fc60555600f760eecadee14d501
            >(),
            contract_address_const::<
                0x7fcc1f75713fa89e2abe49a1ecaf034330a5c2c1e0fd25b1d1b832d132e66c1
            >(),
            contract_address_const::<
                0x74d6250850381d59f0f78c86b177f5889910dbf426b13a54a7f3cff62ebd2f0
            >(),
            contract_address_const::<
                0x30ec1a95db39aa5222c20e9b555a00d5be4612e53d76a464edd9f57f3b04851
            >(),
            contract_address_const::<
                0x7ca534cebc4aafd9248cbada0d9492d1b10bb6ef86e1a9b8671d13b4607618b
            >(),
            contract_address_const::<
                0x746c7c6b63513b3ceeda5b6aea12e4f283adf8e42b733a3be7cce96e0427098
            >(),
            contract_address_const::<
                0x3bd03a23795cba8f1fa580499b8977c5424f2a8ca433c8fdb17469254331603
            >(),
            contract_address_const::<
                0x39b92a0ce806da436df96d46790c0eef3fc06a11eba3f19accd17ab20902a9e
            >(),
            contract_address_const::<
                0x5e2080915b9d0315d70f10728071fbd37301e49f4cfef966a410e1498e1b8da
            >(),
            contract_address_const::<
                0x30157243e521acc690964a8978bd680c5ca969044967892b7c5d0afc221ccab
            >(),
            contract_address_const::<
                0xc2e31a3bd68f09964728c39b475630ae513f376ece9e44cc46644f0de97ab
            >(),
            contract_address_const::<
                0x40199f68dc47419aea94f599691b9846606c2344b8a3368462d4395436f8832
            >(),
            contract_address_const::<
                0x91549c2fe52f07266a21228406131df81b39a7f4793cf23c8cb30d4c667850
            >(),
            contract_address_const::<
                0x7fbe54431c250c3560ffa44b1d7d57b056e320dade627ff6123466dc081b0b7
            >(),
            contract_address_const::<
                0x39ebc7d76900fcaa88c547d3d5efd229f129ab6a074e2bb3845bc007c844766
            >(),
            contract_address_const::<
                0x485605dcd13fd63d5bea3a53d98f1ea5746d8b61cc6a0a889472bf2ea1abcbf
            >(),
            contract_address_const::<
                0x5888d8f6233c824ea415b3bfc27706f9fe815de69e2c8934e603f857861c04f
            >(),
            contract_address_const::<
                0x612d4df45bdc9c392a26905f8612796c5f9614711f18683f9d6d92187a3d584
            >(),
            contract_address_const::<
                0x6ea70a9f54e9bc122e26a6160c69793ab4faebdf186c1225f48d49412b1da08
            >(),
            contract_address_const::<
                0x4ebcf659b5039b185a5d1b7422be578816cbb6b38ab39ad16a32bb0eaee45f6
            >(),
            contract_address_const::<
                0x3cf06ddb5c66f3a1ec139cdeb67f9b93d18b3e6d24c91590fe926fee3c8188a
            >(),
            contract_address_const::<
                0x8a0d3c539c0e0b46d44f82705105ebafee06960485c0ab86db2fc5496f9ed6
            >(),
            contract_address_const::<
                0x3156478365db748eb2a86af3e16d0a9ae9e4436ef333928afdf943d111faf81
            >(),
            contract_address_const::<
                0x52164d1a84a4de0b9b5314f4d702c540cf280465c2f01f64c70d7b33b234a32
            >(),
            contract_address_const::<
                0x17af00991dc672ebaecb73fb81b9b271c927d6cb56836b1cf7d15bce367a946
            >(),
            contract_address_const::<
                0x5fb052346f4d832f7934ea4defd8c6adede55572a06536242c5aaf0e50f05c7
            >(),
            contract_address_const::<
                0x651573d12842fc1abc7fd7e6cb4152f80ad06f594474615f8955352bb651deb
            >(),
            contract_address_const::<
                0x58fad6f9fafcc7b61f604cdebe16f097bd0d7b1d82bbb32c9e2b8467f06b8a7
            >(),
            contract_address_const::<
                0x24355087dd286e7b633fcfe6eb739f6ba97573b207670235374fd86123085a3
            >(),
            contract_address_const::<
                0x6c1fbe5cf8368a21366295aadb99fd41226c8629d7778fa8748286f9ccb0d0c
            >(),
            contract_address_const::<
                0x3f05e110e360f6e26f423dd7632863e2aa7cd0ae4aadef31a7f92a2d4c2f350
            >(),
            contract_address_const::<
                0x3a2e56bbfc34121dcbaf02a02ee14555166b875886e971204bd9359b42cf1d6
            >(),
            contract_address_const::<
                0x7fe401f65712bdfcdd40704a57f67ecc923291bd8a2983537fb00178d647c13
            >(),
            contract_address_const::<
                0x43f05485eafa41da1cd8442069a72a6264dfced0ad1af298fd235d6df91f735
            >(),
            contract_address_const::<
                0x3b5d43847dcc4384c5fbcd2e1994564bb35c054138e9572d36d2b5e72462a38
            >(),
            contract_address_const::<
                0x5d02a1c7ad144b605002ea9e9c2adfaefd08387c345d60461f472c9736decee
            >(),
            contract_address_const::<
                0xa405c40b2a4ca3baf7344caae1b6cd522762c0d35d757ed0cb27ee32fa1357
            >(),
            contract_address_const::<
                0xe17a9779db4a2adc7558e1be7082e8065fe859cd99f1507c047fe6419eb21c
            >(),
            contract_address_const::<
                0x7f5d8e00b8f018beed1b240ef01df8225828993903381b65f8b12c66559f9fc
            >(),
            contract_address_const::<
                0x4aa2d2061270dfa47df32951171b33fd6c822881edc446513b3e5b1a31607e3
            >(),
            contract_address_const::<
                0x4c8f3f49d3d76a34aa1c3f5381b465d0f4c5ce7feed1fbec919808932d16880
            >(),
            contract_address_const::<
                0x6a4bc059bf193b15bfc064179828c985622de5ad319eb849b12c63916cea730
            >(),
            contract_address_const::<
                0x23f87b23c9d4690a3edacf7c403fb039fccdc4c455e246364196a26a60d17ea
            >(),
            contract_address_const::<
                0xa221122b5790c817abeff244a74b23d595d6c6819d10a762fbd2b0f8b29239
            >(),
            contract_address_const::<
                0x26ceec16b0a7e2e57aa90f5eaebc241c6d250a035835efc6bf924715d5a3c19
            >(),
            contract_address_const::<
                0x769798a3c7125be92d025bfb14002ab7c18586d3ecc8f36f0c0e002451f9416
            >(),
            contract_address_const::<
                0x32845a5a9b0c507128dd7127576a301729ed968fc137cb7664716fcd8e704a0
            >(),
            contract_address_const::<
                0x5e653a1c1be68eba18ff4a006ac12a7d27ee70421246805400fd8cc7f7c4ebc
            >(),
            contract_address_const::<
                0x7fb376caff77c932d37b5e3789afa572d3be39721d68f43ff45eb08d1457899
            >(),
            contract_address_const::<
                0x38bb8bddc04cc2bc651f5e30c7d7da595d5b36c2c636bc9826011ed75ef6e7e
            >(),
            contract_address_const::<
                0x46a72443e95a5944f5b7cece1d2e2f8435a77963b912d8376fa4fc41b0f398f
            >(),
            contract_address_const::<
                0x47c9c85df18e141f90632989f9aab21c8b744d4fa9e00f59703123b13eaa523
            >(),
            contract_address_const::<
                0x63cb63d22893aef8bad2d8d123b09542787349198cbb165bef4ce7b533afe21
            >(),
            contract_address_const::<
                0x3c75143521a005ebd8828730dddb2da764e9c7fb6605dcae1a661ee4ab45058
            >(),
            contract_address_const::<
                0x1d3eddff57fd8bf2772c7d8e7603e34f85340b4e1a334afa5d07180e72db7e3
            >(),
            contract_address_const::<
                0x38f3cadd03b2f87fac9ecd0b4ab13474ba0664e3db6e56ed653539af59d4a00
            >(),
            contract_address_const::<
                0x3c97d47df7c6327bb6fe342ca80c486a5177843eeee1f8884ed7d4d7b8e8fa3
            >(),
            contract_address_const::<
                0x60bcb2f399193741fecb033822e5bcb1b23612634f96b56a51f82ace0cc021b
            >(),
            contract_address_const::<
                0x4b1c0be344245ac0f0b1bc21791857a53d368e22ed7455a2411c54615ce96f4
            >(),
            contract_address_const::<
                0x5462bd07df5cd8223ed55457dbacc34839f300ee7486aedddeb0976b465b911
            >(),
            contract_address_const::<
                0x31777a9450c2fa4f1ff347174f1737a859afd81170ecdbb1f195f0898af305b
            >(),
            contract_address_const::<
                0x33b8698bcb5a612f29cc153080d3213ea46545a46010efe25b04f6a525d57f4
            >(),
            contract_address_const::<
                0x170fc25e93098ba290e2b35eafe186c70a7339892bc93bb6fe011cc17e1de82
            >(),
            contract_address_const::<
                0x29993951297c30b5b6b3c967e35632765e539e90654c9fc87bcc5cff29c4cdc
            >(),
            contract_address_const::<
                0x57e890ede07115ef0aa389b2c7de43decf9c2e5092e76b9baab25856a42b69e
            >(),
            contract_address_const::<
                0x72bc9b2b984a57f0daab95b14890c139041cd4c3328d2722c461c8f68f79358
            >(),
            contract_address_const::<
                0x498a356d8d20d581d06ca763d567ff7fc419f620dc7ca6e416c98713ef0b617
            >(),
            contract_address_const::<
                0xf1c169f74df1a1745a5b9a0ba42a245372d6fe21e42098db11785b6d6efaff
            >(),
            contract_address_const::<
                0x3f666b05b3961162ec694734564ccbf049afa5e57fe1272d8b835a29df02e57
            >(),
            contract_address_const::<
                0x872f80d09a42932203ec6ddab79f73268828c9aa29c5966d4c320660e6e847
            >(),
            contract_address_const::<
                0xc396c0076a8aa28bc4373312a7035e75f422a70e87c494655e40753c2d13fe
            >(),
            contract_address_const::<
                0x47c2e95d5b1ca4cfc0f17e2810f356ad36945080dd959ff1d90d2fe8985b69f
            >(),
            contract_address_const::<
                0x1bfd0cf485e021e03a6dd12238f96756c29984351cf5d2c03c17734e4342d6d
            >(),
            contract_address_const::<
                0x13910c9d8dda3fa6330416d6003c2382d257e9c22a1c5ffd2f20069d493f9cf
            >(),
            contract_address_const::<
                0x75c428ceaedf6349905db85c0c6da6e2381bffec9a5122a6c664e5a5d43f077
            >(),
            contract_address_const::<
                0x45f9bc5695f137a6d90dea5f811ad454896ab783c5c7320448bb4e1928d7f19
            >(),
            contract_address_const::<
                0x39482c0b80244fb777efc9e9327add25e5d8c0588dadc7ad16115dd0ce2541
            >(),
            contract_address_const::<
                0x2770a9d4a973e7f66d111998412becaba409469045dc5ba53662d500fd245f0
            >(),
            contract_address_const::<
                0xcd1b505de14500f9266c142b7029825917952ec95fae23661665c68d04f191
            >(),
            contract_address_const::<
                0x81c92f6e157f3f93c1ddd9c332054a99ce6bbd1edda1bf4ad51e1cd323377f
            >(),
            contract_address_const::<
                0x25697a9922bb9cc5421d839ef6a9ea7eed506fe40c4c00e8b27a83ce39aa8f9
            >(),
            contract_address_const::<
                0x66b72a35c87daff2819c28d56345bb9e577485b33a98011ceb475b5d3dac429
            >(),
            contract_address_const::<
                0x7d09ffe79ffbe202fb1ce75bf2117699fcf2a5cf0c5a894ef36b8a99561059f
            >(),
            contract_address_const::<
                0x125cbe5a2d14532d794d4169277a336fef7b6808c688412bd76c978ef25574b
            >(),
            contract_address_const::<
                0x56efa5e1d175a0482c8f47ed9e709e0f058e0c0beaae533297bcd8d097d7d7c
            >(),
            contract_address_const::<
                0x1ed5dde8106315bb414185e1d851c0c0c6b4871e2d084e7f3a6ac1657dd3d19
            >(),
            contract_address_const::<
                0x4617e6fc0736dab08c7e6312769cbb766d59e65ad96a71e4b71d868cf628b1b
            >(),
            contract_address_const::<
                0x37d6e90bfda5a1c498823569873b99b20ae538c0a1dc8e7e0707251e71c2c0f
            >(),
            contract_address_const::<
                0x9de8fa6ae2283733ff9cccd3481621c1ccfcceacd4fe6f72251cf4b991cfbf
            >(),
            contract_address_const::<
                0x3d2ee0de133d84ba27c0f7d9103efa574dc99743ae4b7c7cbd5b97ced5914e
            >(),
            contract_address_const::<
                0x1dd39a78344e6b296c79b8fd06b479f95740070e6b0a2f1d22d00f2e54a72ba
            >(),
            contract_address_const::<
                0x1034c023c08de45759ec01783ac8176e89b37c93797e4f06fa04c8bbc7c38cc
            >(),
            contract_address_const::<
                0x26b5ded122c8920d7940516b91c5df0b5e1b681e59114184f51302cc317306d
            >(),
            contract_address_const::<
                0x1dc8f0c2077757132d16daabc9f9e23336872ac351fd75979f0362dccd1bd49
            >(),
            contract_address_const::<
                0x26f34e739d17d75c1fc1b052fb0b9b06b4f305271935a82b3ba599bbd0d5459
            >(),
            contract_address_const::<
                0x4ff8a37188ebca82092d0ed21442a9920f714d4a0b972ec402a47a65f1adee5
            >(),
            contract_address_const::<
                0x21cfa1ab62008896f10b50d972ed0f53c12eae2cf636b03f47f0962dfdffe6c
            >(),
            contract_address_const::<
                0x302f17a5a997ef73e2cc0db8a1e34b0d446267c5dd619f4b059cdadfd5bc4bd
            >(),
            contract_address_const::<
                0x68bec988bc834658000dc3f4e41475e74be0638b4410a0e0f55df7c2d7f8b53
            >(),
            contract_address_const::<
                0x389effea3e1f23faa4a9b63df4a7916a009f4159e6f9c5c3ea2bbdf63e03a22
            >(),
            contract_address_const::<
                0x446d52b79c9aacdc7d96f9a14aa0bd4ff4391c59b6658b45a9b4a878eac298a
            >(),
            contract_address_const::<
                0x2fc6d71b746c4c264a2e0d4a972265c365dad0e52778e8b50e2cf48d1b5f048
            >(),
            contract_address_const::<
                0x7e5364d80ac4b321964d851a3a14d96fbc0ea3ee8c7ced3c822299756a5135
            >(),
            contract_address_const::<
                0x34dce14d6172fb63c5eb91d03157c01180d6597907e051c43840e413fd5116f
            >(),
            contract_address_const::<
                0x1c70d3bab5db43b6a74b62ed2df6df58ce787f2f710d474fab75101de0d622a
            >(),
            contract_address_const::<
                0x215c710b36cb8f097195a04bce89c5a018cde1ef00d5c1ed9abc949333f5d50
            >(),
            contract_address_const::<
                0x682e603de580b9f36a1488b0f449ed5285d13e2afd0f31431460a70e1a0f8e6
            >(),
            contract_address_const::<
                0x4e2bc9e8c76166741626ab7c60591de00b253d4f07901d6c35c99cdfda6af39
            >(),
            contract_address_const::<
                0x3bb2f9c8438bcb334ec763f2a9b5ca8600f630faf4e06f7ae082f669567d5ff
            >(),
            contract_address_const::<
                0x12519114a36635fd2d2c0a9a6d4d597d77717d0be6fef94f5b8fe43ff27cef2
            >(),
            contract_address_const::<
                0x6ac7327a5685322a68956b14fb2eb7c632133356babade0d0e0dc4951a7a457
            >(),
            contract_address_const::<
                0x3c41277cddff606aad3b3ddb3b9c875df1230eb18f0d53e6b54f6a290ef3a32
            >(),
            contract_address_const::<
                0x49ced74b6309c65bc00ba53ff365d17a3396932cef11c7df31ba8e17c9e1071
            >(),
            contract_address_const::<
                0x4afd95ca9ce0cd53ac5ab05606d7200cd2922714b744fc3730b07e771a59c9e
            >(),
            contract_address_const::<
                0x64fb7f85fd9dee10c313696b0aef1f4afc888ce8422edbc2f1695ec5ed152e9
            >(),
            contract_address_const::<
                0x53183bf5472d0f00e74a2803305e24202906a2c8ed9aadc973bbff80ce23fdd
            >(),
            contract_address_const::<
                0x7cc1b280f690c333ae58b69c23eeb64d3547e731b61a3b533df58f532054c63
            >(),
            contract_address_const::<
                0x4afb154d29666cfa0c81dc13f07cccbeafafdb809a9d53e62d73be0489d91fc
            >(),
            contract_address_const::<
                0x4c14a51656b294489408a6e435ebdb1e9a1f9390d8e06f66999d11b3927bb15
            >(),
            contract_address_const::<
                0x3734654812ca9b65a5cfd94d1001dcdacbe9fb77a583e11433d2e51efd2ebd4
            >(),
            contract_address_const::<
                0x146dc01ddbb52124f3eb755be7d4e8e5e809afe4289874c8f850cec0b5d4ec2
            >(),
            contract_address_const::<
                0x1d03a3e40088955bc7f5518545d4660892e5a428f5868284bdee9681719b71c
            >(),
            contract_address_const::<
                0x7e450124d3bc87d45816f22dfb692615c10b46bfb8b43b03e5f6c5081b8967c
            >(),
            contract_address_const::<
                0x5b74d3db24d7ae23684a06202b3cd3228823bc4f2f00439e4eff216f69af47c
            >(),
            contract_address_const::<
                0x4e0853d961c4fd90472ed0002c122bb835fa473d5b97a1831be60c2e8171f48
            >(),
            contract_address_const::<
                0x261e5a59278b9324ae189d2f5a52ca82494c138ccdb87119c71f59e7593bc74
            >(),
            contract_address_const::<
                0x51dc6d581310c778fdb8ddc144749145af02e54327c0af7b80fc139b14f69c3
            >(),
            contract_address_const::<
                0x1884ccc2e62af7b27339721b59fe65a4cc6f33bc96aff55948e3cf8903efbde
            >(),
            contract_address_const::<
                0x136685aab972a88d904f59b88deaaea9ef631124a4045074f7fcd9a09756abc
            >(),
            contract_address_const::<
                0x7cc81a4ffc22a22d47d35f2a98570b1d7e4ffab4ee797a7b2139c365a069a0b
            >(),
            contract_address_const::<
                0x796e1c8e5f8bd2a9ed26c331b31d2b71cae8a64af7b471b528899423a6d13fc
            >(),
            contract_address_const::<
                0x7c3b62eadf26a009266902c55aba59b8431f0db92b7ed845a95e8e32d95d0a4
            >(),
            contract_address_const::<
                0x358449709cd33f91c0648cd453c0d58dcef4c7532f79870c4b07b260fa32223
            >(),
            contract_address_const::<
                0x3445ecb45134f986ed85878cec4b86b668831784e8fa7a5d31a5811e572e008
            >(),
            contract_address_const::<
                0x58dffd3361083c20e5ad05667d983b4775c69a9606b8ba032c68aee8af99fc3
            >(),
            contract_address_const::<
                0x23eda0bc17c4ac1946b717d26d347c0f8aef99f2f2605770ff4d07558f5ede
            >(),
            contract_address_const::<
                0x1ff66960979c44c8d80f7ace2b47caeb4c5ad75cf32cf6ed5d18c0f595a541d
            >(),
            contract_address_const::<
                0x5f6a70ce7a5b9268b8a02413f7022be7ca691e797e4361c6cfdeebe99f74c2f
            >(),
            contract_address_const::<
                0x5925e7c6e9f7cef652ace81047acb6870785de444ce8c54010ee9f0cba84d2e
            >(),
            contract_address_const::<
                0x1b8fe907f3355b3e0e8a12aeb7d10dcbcfed1db6c40d806cc4d24c5fd714f7c
            >(),
            contract_address_const::<
                0x508a8cafc8bf9086e8330b3598e1df2824ffa4f18b584abeaeef9204b94f456
            >(),
            contract_address_const::<
                0x7a9b4d1d966aeb29b7cb4330600567b1b31600c199681b3dd2b5e2ab93706c8
            >(),
            contract_address_const::<
                0x2fe3ab8a227465eac78753746202018c758d52cc925f68e5ce17a81514b94b8
            >(),
            contract_address_const::<
                0x1a631295d11cab43e961662a63fe6280eeba5b2c46798fd6a04007266de945e
            >(),
            contract_address_const::<
                0x5bb32e0932a38446d677d07ff6c8ea6d65185416f0c38299f43e94bf3d9837
            >(),
            contract_address_const::<
                0x4ca3b23db188ad04d09d7afedcc67eaca812d30b26af1f88a138ca5536370b0
            >(),
            contract_address_const::<
                0x77c1f1fb27cbe4e44b3ca79fc88f0139570cbeac5f0a59dac221ec6d3b80801
            >(),
            contract_address_const::<
                0x565d7d06eaf55a3682f4643861102e9463edaac323aa11e23cc974d30eb072e
            >(),
            contract_address_const::<
                0x32f49ec0384a70268605910829d4af83f2749e3a88a2ef7d02b508bf3d634f9
            >(),
            contract_address_const::<
                0x56c521cc288a1ea5e518d6127f117619dcb783ee6b61fcc5f875c9b90147fac
            >(),
            contract_address_const::<
                0x38aeeb0ff3ffdce5c07c6239cf3ce21bbb6210981d1527f7e1d35377d285a1c
            >(),
            contract_address_const::<
                0x3b5e2e89932222ec6a194f5504df70f890df737efaf99a2a28d2e108cc4fd08
            >(),
            contract_address_const::<
                0x227fe8f198e580f0fcc15da950a2b65a18fe30764a7d7dca88a64bd367e97bf
            >(),
            contract_address_const::<
                0x28fe3167462efc80c070833199496cb86ca845806bd20f15cc72512baa382bc
            >(),
            contract_address_const::<
                0x6de80d8b790ee6ee7ac69518561bd677a5055409b78e86a8f2aa05cb7893462
            >(),
            contract_address_const::<
                0x15d8e53e091fa8c62c25aac9dd6426bc478959425e3c640d5e78de415d8565
            >(),
            contract_address_const::<
                0x7bf93e2969818b65ef497bfa9d1d17d69a1d326d208f72bffc08332b65a2e9b
            >(),
            contract_address_const::<
                0x7ffbd76f48c9162b81c8d7d6094b1126560a8f70dd0a8c403f4014ad400d540
            >(),
            contract_address_const::<
                0x414b6615b7df626a5bf81c640520617134c1e83c7f321f4febc62b8f804b49b
            >(),
            contract_address_const::<
                0x2744317abbb0db31137623ca3eeedcc80ba7f903c2e52e98c63fc381c9613e8
            >(),
            contract_address_const::<
                0x4ebb483c3cbc67d6167e9a29e9f20f18168a64a7965cb582e750a3e4b8f5b34
            >(),
            contract_address_const::<
                0x4fc83a1acc0feff13a03f9b388b9e7ba5e6fdf8d62d79f6249a62ffb3f86aa9
            >(),
            contract_address_const::<
                0x997125f2e52248f348178b79f6f748fbade312fc85507892bf68c66b07760b
            >(),
            contract_address_const::<
                0x6387f32e17dece61f47ed2748b87bdcf0bd301cff1314fc64a99b42260788a4
            >(),
            contract_address_const::<
                0x1b39a755e074feeb9e2c6a6eeb88e46b1c4f070937da568fde4c0491f0eefea
            >(),
            contract_address_const::<
                0x75449e1c319e9f9957c5529dc485e0b12adb630e6c6186c31c4ac893e34d217
            >(),
            contract_address_const::<
                0x549f25ddc3aa812dac7b7fbf9db0263d3e7987f0586c776a9ca7ad006dc5274
            >(),
            contract_address_const::<
                0x1bb3ad999246b63c2b4bd505cb2c339d809fbca08c6835c3831f0aa92027f91
            >(),
            contract_address_const::<
                0x6e01690cbc61c202afdbf73aa9390e979522a40827e59c2b4563f7dcdd562bb
            >(),
            contract_address_const::<
                0x77620549e448b7cbfacff47c5afac002c404cc7319ef3cfcdf9774f21d34dd2
            >(),
            contract_address_const::<
                0x4214ff313044f9a001ee3e44ba55f2b5a58dd11478a6f51646c6fb650c14a06
            >(),
            contract_address_const::<
                0xfac8a9207cdd55f532c6f8321f3038f55fbe71b5448428b5c5e94d262219be
            >(),
            contract_address_const::<
                0xa0640d6c07b15985cff54547345686f657439149a07fbad2bac50a6ebabf2c
            >(),
            contract_address_const::<
                0x34feae952dc2559b8b684c52ef13619ba835e1d1e6faa02728c93d73b092575
            >(),
            contract_address_const::<
                0x58138799056d7a7b1f2cc381365b80c79d61073f436a970de51a13d320de212
            >(),
            contract_address_const::<
                0x43ef00656285f1c1d11db93b608d3ec943da49fc4430599fe4774cbd86e9fa9
            >(),
            contract_address_const::<
                0x74e085ba86f8af2fda6f9b6975b668956ca9aff5042abf4859414d4b58691e
            >(),
            contract_address_const::<
                0x34445c99330e161fde72fd5ed088cdc412493fa3a7ece0cec75eeb3c11ea5ac
            >(),
            contract_address_const::<
                0x92cc9b7756e6667b654c0b16d9695347af788efbc00a286efe82a6e46bce4b
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_defi_spring_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x067138f4b11ac7757e39ee65814d7a714841586e2aa714ce4ececf38874af245
            >(),
            contract_address_const::<
                0x0078fa1dacfb1ad906f739f23cec37e6213995258bb4494d060dbc50ef5c9386
            >(),
            contract_address_const::<
                0x0492b83384b1c2320e1dfd7a603ead84bfdf03fe73b821edc48512c14706057a
            >(),
            contract_address_const::<
                0x04effd24e62ca7a207ebcad9e1663560f758ccb40941e2335f2ea4664d38a47d
            >(),
            contract_address_const::<
                0x03ded7955cffdf07ffae6f910e0fe9e79541844e455fa097ed88c6d0f82387db
            >(),
            contract_address_const::<
                0x07254bef61fe57adfe0be04953265cb0ca49ce8f5f2a6a97aedca1a3042a904c
            >(),
            contract_address_const::<
                0x004413f198ebd6f1bec5ec19de728e104901123f8a45bf19037cdcfb70d39972
            >(),
            contract_address_const::<
                0x0073a0614ad81ad7bfad711016e82c08024691c2ebfce8986da61f637c3fc6c4
            >(),
            contract_address_const::<
                0x004413f198ebd6f1bec5ec19de728e104901123f8a45bf19037cdcfb70d39972
            >(),
            contract_address_const::<
                0x0703074cc1ce84d4e66825595ed319054ecf7c59e66368c8848a23cf4d61c6ca
            >(),
            contract_address_const::<
                0x07067cbe811943269ea7f1a16e27a128edb75b53fb5cf2e7f959cbb641cdea80
            >(),
            contract_address_const::<
                0x0378c104758d8b56f85c7259c7a763e5298a48ffea14f532c5f744309de08291
            >(),
            contract_address_const::<
                0x05ce280a7898692e25329b04703494439ac23abbac3f9ae8ae6f73ce8052d463
            >(),
            contract_address_const::<
                0x007cb5687d7bfbc76a86f93a4dba205e34c2d02a649f4a96073109c6195b7270
            >(),
            contract_address_const::<
                0x0081dc695bcbf6568c8f01aeec68c66fb32963ea75c50ca62ca7d02eb8c24274
            >(),
            contract_address_const::<
                0x06943f65e82c6c76678714c9f89a58dc0cf64d3e1eda5d41d591a5dbe60a0c22
            >(),
            contract_address_const::<
                0x039df814ec71eb41b934250ca7ec9e67083279bd253e0fb6336e6f6ca24e5134
            >(),
            contract_address_const::<
                0x00296a1ca51ce445a9749d2e6f97a6e2f9904e60f4102b21db50753cc7f58858
            >(),
            contract_address_const::<
                0x07956d55bd6529fefe1c44151b3480fcc234c686c86b53f2f433d55d62114dd5
            >(),
            contract_address_const::<
                0x0200053497400e49a705b6be0483249625d59bafd965ce933e934b387eb2ed06
            >(),
            contract_address_const::<
                0x04a715990b18da35aa213ea7060d803b743743f87f0d638237a1ea34484879e6
            >(),
            contract_address_const::<
                0x03088fbcc4bde5c69b034ec7a37ed2d0cc6b33cc4aadff682c160b2a34b3c680
            >(),
            contract_address_const::<
                0x04b231d43217329251591346297c184970e9f84a97237293a7298ee1804fa8e4
            >(),
            contract_address_const::<
                0x0234f5f4d6f8832c7c1c3568e150a600e78d942766804190920cb4e81e057cf1
            >(),
            contract_address_const::<
                0x002a13e33e5e850d1747ca6f4957aa70a84e75724a4f13fbd7f94c6f41d1ee68
            >(),
            contract_address_const::<
                0x005d13967477c18e3af591c71f10163fca12360c99d9f1c1c48e9c8626742dee
            >(),
            contract_address_const::<
                0x07c4916f38db9beaa0c01fac4dfec32b6b5957bdddd40078aec70f4104a5886a
            >(),
            contract_address_const::<
                0x0018a35ea1fd0bd8db4b8f71f81265bc2ec226f1bace3a62c26dc5835254f47f
            >(),
            contract_address_const::<
                0x01a224c095d0a241ca8e2c227d954709da3f22e38f3aab93e761ebd85aa66ecb
            >(),
            contract_address_const::<
                0x06267e1da78d7a9081b5d5701805656d8eaef7b9e8a4959c49a3bd90b1baae60
            >(),
            contract_address_const::<
                0x066663598d1120f97aad74bccc0c162f89f12b8a3fa444f6caacb6bccc500600
            >(),
            contract_address_const::<
                0x04beaae093164845351e0f2c4e346749304be17639cd642d690365308d04566a
            >(),
            contract_address_const::<
                0x05d9d01090b1955f6551408755c1c6d9a553e821614f0944d78fb6ff4b9717a7
            >(),
            contract_address_const::<
                0x05aed32c092b4d597e524160d749c4ac4bfe38960693b79f3c407e9fdf6ec7f4
            >(),
            contract_address_const::<
                0x0479bba34c97636834239a461327ccea0e6fa79debcf12f6ede8da35e8aedca1
            >(),
            contract_address_const::<
                0x02fe01fd00a4b535c3254cb7c062ed643a78fbc4dd0b4578873c2ae7e67d607d
            >(),
            contract_address_const::<
                0x01fb62ac54f9fa99e1417f83bcb88485556427397f717ed4e7233bc99be31bff
            >(),
            contract_address_const::<
                0x0718505b87b5a448205ae22ac84a21b9e568b532ed95285c4c03973f8b1a73e8
            >(),
            contract_address_const::<
                0x01115a8b9e4a9a1a1581f3de2ede55202d59493eaeccb2a4f653ff22098db252
            >(),
            contract_address_const::<
                0x07422c7d95ad9b88e1d010b364503138084b88ec87a4eddd4e4590a0d6dfe21a
            >(),
            contract_address_const::<
                0x039a8695ad2d2d0b60691c3214a89686df5de8b38c41afd75260b60e67360787
            >(),
            contract_address_const::<
                0x067b5f23b31954e1b31b219edc524d997287ca6d45259d7f6a939019d358ebe2
            >(),
            contract_address_const::<
                0x00452ed0eeeb5b3d9cc9742a0c8f327ccc68d6722a81ad2b774976a4981b95b3
            >(),
            contract_address_const::<
                0x038d8fda0c547ae4fa3b9190fb4dcd31f6c51240c5cc3809ace1d2c8f2cd8808
            >(),
            contract_address_const::<
                0x059d5c51ee0c84334c5721994b212caa2bad5cd436b0854396fc4bb8b9e1cacd
            >(),
            contract_address_const::<
                0x0797470c11c2b829ccf0f7cfd29a0327c1947de9daa0badc26b6d2bdc0e261f0
            >(),
            contract_address_const::<
                0x06437446ec928d42567d303566b48cdb46c1a0bcdea878c5b87f32045c916124
            >(),
            contract_address_const::<
                0x004b878177f4f2072308011c2c31a8f7e58ae1a1d989ca69cc39b002623639c8
            >(),
            contract_address_const::<
                0x0583a9d956d65628f806386ab5b12dccd74236a3c6b930ded9cf3c54efc722a1
            >(),
            contract_address_const::<
                0x05816b1b9bcfb236af695c0227c7039752c2bea9b240292caee49b35a7c68a12
            >(),
            contract_address_const::<
                0x075d36c7c33c4ba471ec71f94817e2933ee88dab884db2875f60dcd44a72ce2a
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_golden_token_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x0727930d62456a75997833d02f208024059e75dfbdff61003a7d6900038b7bdb
            >(),
            contract_address_const::<
                0x0421b5163cc506e3dc39f56769f8b8e2bc94aa12030bf33d2d491cd0f4c784cb
            >(),
            contract_address_const::<
                0x0727930d62456a75997833d02f208024059e75dfbdff61003a7d6900038b7bdb
            >(),
            contract_address_const::<
                0x01f447b1d086c66533b481311813a68cde116aacf39fb9611636f18c79502241
            >(),
            contract_address_const::<
                0x00d730a5ed5d17622f931ea88ffcda5bceec128981204ed5e40b90300e8e5998
            >(),
            contract_address_const::<
                0x04bb65481356e24834321323cc2265347ef515a1a7b535bcf09c694010bcf4f8
            >(),
            contract_address_const::<
                0x0125559ab972689d8fadbae2e236f76a44e382d82d710e825171a9efde96fc7f
            >(),
            contract_address_const::<
                0x04649766c7c55a0ca90f18b8c6a20f990e77de5a5c65e369c75a001668f6726c
            >(),
            contract_address_const::<
                0x066f04f184ddbc8e10d53540b724a336bda64222d916f277030ec9d99cf99460
            >(),
            contract_address_const::<
                0x0621eb4999d324a1a1d98789a5146b5d203fd2b2ed4cebd7e7460bd360ab2487
            >(),
            contract_address_const::<
                0x069cca516f5f6fd67e007bc73808e908755b3fd9a87e4856a05d8c6536688674
            >(),
            contract_address_const::<
                0x02dd93bcfc6dcb21083f9e045066c54a45e0aefb00a6c79eb5286ee0e1801504
            >(),
            contract_address_const::<
                0x066f04f184ddbc8e10d53540b724a336bda64222d916f277030ec9d99cf99460
            >(),
            contract_address_const::<
                0x05070f241e91afc70eed5697e550c207fa15f39b567b1dbb04ebde1c2b575ca4
            >(),
            contract_address_const::<
                0x078af09fa0375abc96a33dec1adc69438f60c49e5b7226662c3123437126a838
            >(),
            contract_address_const::<
                0x078af09fa0375abc96a33dec1adc69438f60c49e5b7226662c3123437126a838
            >(),
            contract_address_const::<
                0x078af09fa0375abc96a33dec1adc69438f60c49e5b7226662c3123437126a838
            >(),
            contract_address_const::<
                0x078af09fa0375abc96a33dec1adc69438f60c49e5b7226662c3123437126a838
            >(),
            contract_address_const::<
                0x078af09fa0375abc96a33dec1adc69438f60c49e5b7226662c3123437126a838
            >(),
            contract_address_const::<
                0x078af09fa0375abc96a33dec1adc69438f60c49e5b7226662c3123437126a838
            >(),
            contract_address_const::<
                0x0578908083f89ebdf746a241c71290826fca4cbf9f14f85573f619c5e00f6aba
            >(),
            contract_address_const::<
                0x0437f0c46545db400f40fffdbc8a34090c506d1a1bb25aeb500cc3c884c94e54
            >(),
            contract_address_const::<
                0x040199f68dc47419aea94f599691b9846606c2344b8a3368462d4395436f8832
            >(),
            contract_address_const::<
                0x0011fe46807c2b2040a6b7351f742d76379c574bf220e55bd91bd2f53d7666ba
            >(),
            contract_address_const::<
                0x040199f68dc47419aea94f599691b9846606c2344b8a3368462d4395436f8832
            >(),
            contract_address_const::<
                0x071538f6445e0c6179b786230a3e7b5ddee40b72673a9b5a395da20f4657bdca
            >(),
            contract_address_const::<
                0x03ef24583abdb73b7311cab6144c3f0d3ce01a23c70eb7b254b8d849d7d9ec40
            >(),
            contract_address_const::<
                0x060391c8d5226fcfdc7cdf1c57a88574844db9151dba51981d50ac9709b71e9b
            >(),
            contract_address_const::<
                0x02c21c962f31fe02e2623b8edcec741b328287afad0a8493d03433409a88d919
            >(),
            contract_address_const::<
                0x071c1f96e59bb1e272edc218e14ff7d28ccd1f9467a9b8d87012907c99dd0dc6
            >(),
            contract_address_const::<
                0x003e45b5303c872c58c0fdd174dbbaa484f14c4c9b7fdb66ea1e8f2b72ab6b69
            >(),
            contract_address_const::<
                0x0493259cc9835eef0b96cb1b0d584ed49ebd3deb5eb0e0754b785cce0586014b
            >(),
            contract_address_const::<
                0x077f3b0cd4cfbb2399ea2f7a8f1ed77414dc045d8782b3349bf587331775bab9
            >(),
            contract_address_const::<
                0x058b474d9df39dcdd7f88d50cfb93d61943ef2f2453a1dae58e806bbf1133804
            >(),
            contract_address_const::<
                0x04afd95ca9ce0cd53ac5ab05606d7200cd2922714b744fc3730b07e771a59c9e
            >(),
            contract_address_const::<
                0x057d583246bdda7fc818b98218d066918fab35eff2f2491626eaf658d3ecc5a9
            >(),
            contract_address_const::<
                0x011f731018cb76b6ce62624e9cdcf91213747c511aefe3571195f031179d62db
            >(),
            contract_address_const::<
                0x02fd139d7b8cb30797e6696081ad1dc3cae9f1be9f1bd427cb0c955ab33ad98f
            >(),
            contract_address_const::<
                0x05b7b2b35451b7454cfbfe1ef73302feb56863efb475becbd55d5a69184d4e09
            >(),
            contract_address_const::<
                0x065cd8f9ad65ddb8a4df36e3df32d60f24f44dc5acdb4c4b0e83ef4dc0d7f5b6
            >(),
            contract_address_const::<
                0x007d3246639ed9e666c5ceb9b4dc533f731af1c866487977e0474d0465a73426
            >(),
            contract_address_const::<
                0x07e2e292250270f1cfef897350112f6d755669c2bd871b729c0c20b1a5bf5ff4
            >(),
            contract_address_const::<
                0x049c825710365f3cd0a8fa61e27368197b47727a4d0a78981cc2b19febaef9bd
            >(),
            contract_address_const::<
                0x049c825710365f3cd0a8fa61e27368197b47727a4d0a78981cc2b19febaef9bd
            >(),
            contract_address_const::<
                0x049c825710365f3cd0a8fa61e27368197b47727a4d0a78981cc2b19febaef9bd
            >(),
            contract_address_const::<
                0x049c825710365f3cd0a8fa61e27368197b47727a4d0a78981cc2b19febaef9bd
            >(),
            contract_address_const::<
                0x049c825710365f3cd0a8fa61e27368197b47727a4d0a78981cc2b19febaef9bd
            >(),
            contract_address_const::<
                0x049c825710365f3cd0a8fa61e27368197b47727a4d0a78981cc2b19febaef9bd
            >(),
            contract_address_const::<
                0x049c825710365f3cd0a8fa61e27368197b47727a4d0a78981cc2b19febaef9bd
            >(),
            contract_address_const::<
                0x049c825710365f3cd0a8fa61e27368197b47727a4d0a78981cc2b19febaef9bd
            >(),
            contract_address_const::<
                0x049c825710365f3cd0a8fa61e27368197b47727a4d0a78981cc2b19febaef9bd
            >(),
            contract_address_const::<
                0x07c97b945761e17f4344d0b4982697904e2d89c741f9fed80f83647a873ac759
            >(),
            contract_address_const::<
                0x075994b019fd5e15e3e78b97b77cb538d572f8f8f722ea4ed85b0c855ad6fe28
            >(),
            contract_address_const::<
                0x0289b32c42af63fa508c76bdbb2250e447c5ba9bc938ab0a9629d25b1b8aedd0
            >(),
            contract_address_const::<
                0x01558beea1b77efa21d82c635b7540c75b88cc5dc777e79871bebde413438d12
            >(),
            contract_address_const::<
                0x018eadef1e2717e91f9107b894fc1b081cafc4b5c5083dad7471c45a8d454afb
            >(),
            contract_address_const::<
                0x02dd93bcfc6dcb21083f9e045066c54a45e0aefb00a6c79eb5286ee0e1801504
            >(),
            contract_address_const::<
                0x010afc0a4f0625dc9f2de80b5fce67fa212776773848c795a218d6bb40589265
            >(),
            contract_address_const::<
                0x066f04f184ddbc8e10d53540b724a336bda64222d916f277030ec9d99cf99460
            >(),
            contract_address_const::<
                0x01046e44faf09e4e69ba96180a545882e196c34ffcfc3598c4ab15a3a442d319
            >(),
            contract_address_const::<
                0x0664e2de62463c8f349a4b9c8b45b5e90970b66e4dd1b942dfaac3e4047d072e
            >(),
            contract_address_const::<
                0x02cd97240db3f679de98a729ae91eb996cab9fd92a9a578df11a72f49be1c356
            >(),
            contract_address_const::<
                0x04c8f3f49d3d76a34aa1c3f5381b465d0f4c5ce7feed1fbec919808932d16880
            >(),
            contract_address_const::<
                0x0074e085ba86f8af2fda6f9b6975b668956ca9aff5042abf4859414d4b58691e
            >(),
            contract_address_const::<
                0x021cfa1ab62008896f10b50d972ed0f53c12eae2cf636b03f47f0962dfdffe6c
            >(),
            contract_address_const::<
                0x0685a35d653d54f8e6edf257be18d616f1dea4a26068bce94398a17ca04a480c
            >(),
            contract_address_const::<
                0x051102de9c077ba26886ea9533c9d6bdbc55550b1cd88969b747df22a9c595ac
            >(),
            contract_address_const::<
                0x03474353878b236171e4c08e52465d9f2cf6c3babf726cc292ff1566e68612c3
            >(),
            contract_address_const::<
                0x06f490c0ec49fe17148af6f83ebebd9d31e5a06dc46bdbe5c5e0657c23a4ff4f
            >(),
            contract_address_const::<
                0x06f490c0ec49fe17148af6f83ebebd9d31e5a06dc46bdbe5c5e0657c23a4ff4f
            >(),
            contract_address_const::<
                0x02a42d936e7cc9484a193a512ec7de42f57c9f792ea4e096f06e26de8cbcac63
            >(),
            contract_address_const::<
                0x0754fb29f8c4ceca0c1b6423e90c1d833fa4d726120ab16d9a4e31f04f70db1b
            >(),
            contract_address_const::<
                0x00a0e96f3ceb8dfab7f4c8b5c1a5e6f951917409cf54f89497b3dc642e96a3fb
            >(),
            contract_address_const::<
                0x0757f2020f8d396072e9b3ad3806251107b7d4fb7630ea0aedb6db929fad62bf
            >(),
            contract_address_const::<
                0x07c11cceaf0008e0bb3e1e138eda9702e8e96ca759cc540e0534871d227b429e
            >(),
            contract_address_const::<
                0x07c11cceaf0008e0bb3e1e138eda9702e8e96ca759cc540e0534871d227b429e
            >(),
            contract_address_const::<
                0x07c11cceaf0008e0bb3e1e138eda9702e8e96ca759cc540e0534871d227b429e
            >(),
            contract_address_const::<
                0x0752bada3baecf7d11d891dc445df6d8a6b4cfcb5655bb8e01b711a127d08c84
            >(),
            contract_address_const::<
                0x0079d57dd558fd1882cd30beb8490da8179694acc7756570b03cc4428ad54664
            >(),
            contract_address_const::<
                0x01187c746b07886c440a39e7adf4a270351f49cb3523550e19fa344229912536
            >(),
            contract_address_const::<
                0x02fd139d7b8cb30797e6696081ad1dc3cae9f1be9f1bd427cb0c955ab33ad98f
            >(),
            contract_address_const::<
                0x0552123e29251181ce3509edc236dcd87f8e1448e47b40dc44f27e866f257188
            >(),
            contract_address_const::<
                0x02dd93bcfc6dcb21083f9e045066c54a45e0aefb00a6c79eb5286ee0e1801504
            >(),
            contract_address_const::<
                0x037f225e7f1d10624509ed066e031ec06418f7a7839583f5841af3cacac3bf3e
            >(),
            contract_address_const::<
                0x07266c8d2cf45ecba9221e7691f80fb3e6c4ff30b09f6a3a1097341a2f3f14de
            >(),
            contract_address_const::<
                0x03ff12a12279a8b4aa744b818144a01d3ce59a1041e4b3589087334e4aa48a3f
            >(),
            contract_address_const::<
                0x066f04f184ddbc8e10d53540b724a336bda64222d916f277030ec9d99cf99460
            >(),
            contract_address_const::<
                0x06e280029a6ec58f1f1d7112c8f46c10d3b0c9bda13d283ac6f444b7112fca8a
            >(),
            contract_address_const::<
                0x016ead2d8db97dfd24fe65cf8568184369486d5e78312a065a4af0815f371513
            >(),
            contract_address_const::<
                0x018a6c29723b5ca726e929430996432ed65894138d85f4813a66a3a7a1487334
            >(),
            contract_address_const::<
                0x0421b5163cc506e3dc39f56769f8b8e2bc94aa12030bf33d2d491cd0f4c784cb
            >(),
            contract_address_const::<
                0x02dd93bcfc6dcb21083f9e045066c54a45e0aefb00a6c79eb5286ee0e1801504
            >(),
            contract_address_const::<
                0x039f870c7093c1aaa7db25261a752bb6f604ebe509b4d64f1b6e4633318ab3a3
            >(),
            contract_address_const::<
                0x039f870c7093c1aaa7db25261a752bb6f604ebe509b4d64f1b6e4633318ab3a3
            >(),
            contract_address_const::<
                0x039f870c7093c1aaa7db25261a752bb6f604ebe509b4d64f1b6e4633318ab3a3
            >(),
            contract_address_const::<
                0x039f870c7093c1aaa7db25261a752bb6f604ebe509b4d64f1b6e4633318ab3a3
            >(),
            contract_address_const::<
                0x04b72f3639f481b551b6c8b55a956a54ec70c3fa8ff232276e76cd822ef039a3
            >(),
            contract_address_const::<
                0x018d7624edeb8d52c54dd77219726920f286d14090739962d9ee9938139ac272
            >(),
            contract_address_const::<
                0x039f870c7093c1aaa7db25261a752bb6f604ebe509b4d64f1b6e4633318ab3a3
            >(),
            contract_address_const::<
                0x0602aa0003c51cce5c7c94b05d06a383cb5129a5088cfd9a6b5ef290143beeeb
            >(),
            contract_address_const::<
                0x0011fe46807c2b2040a6b7351f742d76379c574bf220e55bd91bd2f53d7666ba
            >(),
            contract_address_const::<
                0x04645f67e3e195420b2b4e63742153623e50c143ed8b89c91e3fb908fe87b168
            >(),
            contract_address_const::<
                0x04e00be7ea81f112862e5b137a1e6e62bc4a82ff6aa811559fe94369bc9ec90b
            >(),
            contract_address_const::<
                0x04e00be7ea81f112862e5b137a1e6e62bc4a82ff6aa811559fe94369bc9ec90b
            >(),
            contract_address_const::<
                0x04e00be7ea81f112862e5b137a1e6e62bc4a82ff6aa811559fe94369bc9ec90b
            >(),
            contract_address_const::<
                0x03d85759add09b3318a002ddc57f81c67286fdde869cbbdaa39ceb17c0661e6f
            >(),
            contract_address_const::<
                0x05b0a0def8c8eea7c4b1002502386c067d218d95a8346b0842f7b8cd53447201
            >(),
            contract_address_const::<
                0x07a1d33e49fdeb6cd02e9eb92e5a32b9f308d766b3293147e64815998e744240
            >(),
            contract_address_const::<
                0x002776adfd53f0aea3586416bb8f275ee0e729c718a32b6d5fffa3e0d3cf95ef
            >(),
            contract_address_const::<
                0x07bae6a7e209cfe5d2f29e84b226f68e9d538d9e36db09f1363120adb6f5d0a9
            >(),
            contract_address_const::<
                0x01ac519950fe43b010547c9ee01aa5d20e304e86244e18eab45605d4cfb0fb2e
            >(),
            contract_address_const::<
                0x054b69d9f4d8c613f0ee5b9247eb654f23e01e91a672f376cdbc79883c8d9d22
            >(),
            contract_address_const::<
                0x0378b9c3cb6be32d087d1af8a91c1484226ac8b009f502e12b06ffd46d94f014
            >(),
            contract_address_const::<
                0x021cfa1ab62008896f10b50d972ed0f53c12eae2cf636b03f47f0962dfdffe6c
            >(),
            contract_address_const::<
                0x04e4910b6a27bed46d9f6d3605b6ad4bf42a5af5d2212c98dc2e71d276e8d88f
            >(),
            contract_address_const::<
                0x01ed5dde8106315bb414185e1d851c0c0c6b4871e2d084e7f3a6ac1657dd3d19
            >(),
            contract_address_const::<
                0x01ed5dde8106315bb414185e1d851c0c0c6b4871e2d084e7f3a6ac1657dd3d19
            >(),
            contract_address_const::<
                0x04f26707a949ea2143c3a5ec6751ab93433f6323472321c13530fc2709b42e1b
            >(),
            contract_address_const::<
                0x051102de9c077ba26886ea9533c9d6bdbc55550b1cd88969b747df22a9c595ac
            >(),
            contract_address_const::<
                0x027b9a4d5dbb93f09ab85d6cd2b3949711c866d2e0dfa8b4a364ad55b5e88da3
            >(),
            contract_address_const::<
                0x01e850ccf1f74d839ed9cefbc589e5b5730f5db65616b6725a5de8bbf7a10d7c
            >(),
            contract_address_const::<
                0x04cb4e415bced2d487f78e7b52ab794c2c1688e1be5264ecf0b80a458c1bc57d
            >(),
            contract_address_const::<
                0x0154c4a6e48b66bd77e8c7786e2de6a037af7104cfbec10f9fb2e5cedc0e56b1
            >(),
            contract_address_const::<
                0x074c2664cfc8aff6b1e24befa444488f89a060f9a58550cd5ef1f9c4809a80c3
            >(),
            contract_address_const::<
                0x066f04f184ddbc8e10d53540b724a336bda64222d916f277030ec9d99cf99460
            >(),
            contract_address_const::<
                0x06941d918f463740616e7e2b97498a2bad4d771a5589b0e598a42066e59307ee
            >(),
            contract_address_const::<
                0x060ca8040b63d9ae38f77a3d7817cbcc6b0b52dcc4b812b53ff82270bf2fa96e
            >(),
            contract_address_const::<
                0x06984560836d038e6e42226351eb70e627afc7879df11aa3cfc383d41f6701a2
            >(),
            contract_address_const::<
                0x06984560836d038e6e42226351eb70e627afc7879df11aa3cfc383d41f6701a2
            >(),
            contract_address_const::<
                0x04e8fa25c1c786bb014311ed21cd5c5e0aa0b44a276fa6c6775f26febaaed2fb
            >(),
            contract_address_const::<
                0x03d379ddda2ea79a4c5cc6395fd587f59a6458bde3ef22393755d51abec59fae
            >(),
            contract_address_const::<
                0x0245e8b6171b3f453bd13997d600c0652ad675a9265e49249a6c333a3796be4b
            >(),
            contract_address_const::<
                0x04042b3f651f6d6ff03b929437adc30257333723970071b05cb0e2270c9dc385
            >(),
            contract_address_const::<
                0x04042b3f651f6d6ff03b929437adc30257333723970071b05cb0e2270c9dc385
            >(),
            contract_address_const::<
                0x0548a097e9f822b2af3ebf7b611e3b0d22283530d9c3ce1e524d5ec87fb9848c
            >(),
            contract_address_const::<
                0x044081ea31b076fd7daf9f66e5405a64bf3f6384d9ffea6c6b8c45e5524c60f3
            >(),
            contract_address_const::<
                0x01d92fa8647270d5dafb0b32a98f11297c1cc2b12f3c49d7e249a8f9efe20d69
            >(),
            contract_address_const::<
                0x0114e1776e7fae7535818758ee00dee9e8a0e4ffdcf3db44a66dec94dcdc163e
            >(),
            contract_address_const::<
                0x03022b3a644e4d220eaf8390f235ac721e543930bdd5b9298378726f53ecbc51
            >(),
            contract_address_const::<
                0x0591333f20737c91c1ea5bc1abe0e53cacb0b70d0cad4a568af965316352e45d
            >(),
            contract_address_const::<
                0x05ca28c35a857fda6bc260649a1ed140d6d6c494cf82e4462f5418874cdd3cc5
            >(),
            contract_address_const::<
                0x03484e299d480b980c420b895850ee01b1c39011731d1b657ecd6fbf142b6939
            >(),
            contract_address_const::<
                0x040199f68dc47419aea94f599691b9846606c2344b8a3368462d4395436f8832
            >(),
            contract_address_const::<
                0x040199f68dc47419aea94f599691b9846606c2344b8a3368462d4395436f8832
            >(),
            contract_address_const::<
                0x066f04f184ddbc8e10d53540b724a336bda64222d916f277030ec9d99cf99460
            >(),
            contract_address_const::<
                0x04461b5e6a40da71a2ea718e8e2cbde18109f5d55ec3ffc29f44086d8a7a6649
            >(),
            contract_address_const::<
                0x0774a38e73bec6655a258ca3ecf2e0f320555c9ef005f371aa6b0336a2fd3b62
            >(),
            contract_address_const::<
                0x06f490c0ec49fe17148af6f83ebebd9d31e5a06dc46bdbe5c5e0657c23a4ff4f
            >(),
            contract_address_const::<
                0x06f490c0ec49fe17148af6f83ebebd9d31e5a06dc46bdbe5c5e0657c23a4ff4f
            >(),
            contract_address_const::<
                0x0261069892eca8e8d4d45b31a36eed8b188aaa9c3b4afc43e799f6a8ee3ff158
            >(),
            contract_address_const::<
                0x03811acc9d5de9c40713c72e690412ab92814ccab12c39f7cdd52f1693180b2a
            >(),
            contract_address_const::<
                0x03ef24583abdb73b7311cab6144c3f0d3ce01a23c70eb7b254b8d849d7d9ec40
            >(),
            contract_address_const::<
                0x06a84c1f9864778fcca79da6995eb4a47fdcaa0d5d64bda7a766bc420bc266e4
            >(),
            contract_address_const::<
                0x074f91d284351a8603933b648684b6a990126d7c78a1b867353a57a3bc2097da
            >(),
            contract_address_const::<
                0x0154c4a6e48b66bd77e8c7786e2de6a037af7104cfbec10f9fb2e5cedc0e56b1
            >(),
            contract_address_const::<
                0x0716e39b21fe7062421cb0056e1e3323ded9e9154915c0e89f1c9dff206ba459
            >(),
            contract_address_const::<
                0x071538f6445e0c6179b786230a3e7b5ddee40b72673a9b5a395da20f4657bdca
            >(),
            contract_address_const::<
                0x074c2664cfc8aff6b1e24befa444488f89a060f9a58550cd5ef1f9c4809a80c3
            >(),
            contract_address_const::<
                0x0437f0c46545db400f40fffdbc8a34090c506d1a1bb25aeb500cc3c884c94e54
            >(),
            contract_address_const::<
                0x0154c4a6e48b66bd77e8c7786e2de6a037af7104cfbec10f9fb2e5cedc0e56b1
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_loot_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x067074c26d36f899e658e1920d2a9b0b100cea7325d4b8b9e6c90895d391b31e
            >(),
            contract_address_const::<
                0x02Bc9bbD6aBdFc745918827D9438052d854F079F3Dd91739B45dfbe5B0f54B5C
            >(),
            contract_address_const::<
                0x058122e17c8521a08f6bc9c20f2963f6a3b4ff338fb910fccd1e19fa17827f1e
            >(),
            contract_address_const::<
                0x03858F95e136B3EE520B224dbb7f6b1dc954D993fC773b73785ca949733FbD3a
            >(),
            contract_address_const::<
                0x0438fCf3c887299aeAF6d3EE8eF14626219b7E4eb1f06a0a3A5CBedDB041d1d8
            >(),
            contract_address_const::<
                0x067270739eD87F655edc5cCFB60805747Ade39B3A6C6F7a495A76D4b9ed62102
            >(),
            contract_address_const::<
                0x00a713449621A87918438C335880a49681413a86A679DDA44a6f184B08b24f4F
            >(),
            contract_address_const::<
                0x06bb255ed5b41d598624dd54536104e2cc149aa674924650169d94f2f7a4d2f0
            >(),
            contract_address_const::<
                0x02dD93bcFc6DcB21083f9E045066c54A45e0AEFB00a6C79eB5286eE0e1801504
            >(),
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

    fn airdrop_dojo(ref self: TState) -> u16;
    fn airdrop_starkware(ref self: TState) -> u16;
    fn airdrop_argent(ref self: TState) -> u16;
    fn airdrop_dope_wars(ref self: TState) -> u16;
    fn airdrop_1337(ref self: TState) -> u16;
    fn airdrop_stark_id(ref self: TState) -> u16;
    fn airdrop_defi_spring(ref self: TState) -> u16;
    fn airdrop_golden_token(ref self: TState) -> u16;
    fn airdrop_loot(ref self: TState) -> u16;
    fn set_loot_survivor_address(ref self: TState, address: ContractAddress);
}

#[cfg(test)]
mod tests {
    use core::num::traits::Zero;
    use snforge_std::{
        declare, ContractClassTrait, start_cheat_caller_address_global,
        stop_cheat_caller_address_global
    };
    use super::{
        IERC721MixinDispatcher, IERC721MixinDispatcherTrait,
        Syndicate::{
            get_dojo_addresses, get_golden_token_addresses, get_loot_addresses,
            get_starkware_addresses, get_argent_addresses, get_dope_wars_addresses,
            get_1337_addresses, get_defi_spring_addresses, get_stark_id_addresses
        },
        Syndicate
    };

    // this test exceeds maximum number of events emitted (1000) so it needs to be split up
    // #[test]
    // fn test_airdrop_all() {
    //     let contract = declare("Syndicate").unwrap();
    //     let (contract_address, _) = contract.deploy(@array![]).unwrap();

    //     // Test address
    //     let last_owner = starknet::contract_address_const::<
    //         0x065d2AB17338b5AffdEbAF95E2D79834B5f30Bac596fF55563c62C3c98700150
    //     >();

    //     // Create a dispatcher
    //     let dispatcher = IERC721MixinDispatcher { contract_address };

    //     dispatcher.airdrop_dojo();
    //     dispatcher.airdrop_starkware();
    //     dispatcher.airdrop_argent();
    //     dispatcher.airdrop_dope_wars();
    //     dispatcher.airdrop_1337();
    //     dispatcher.airdrop_stark_id();
    //     dispatcher.airdrop_defi_spring();
    //     dispatcher.airdrop_golden_token();
    //     dispatcher.airdrop_loot();
    //     let token_owner = dispatcher.owner_of(300);
    //     assert(token_owner == last_owner, 'Invalid token owner');
    // }

    #[test]
    fn test_airdrop_dojo() {
        let contract = declare("Syndicate").unwrap();
        let (contract_address, _) = contract.deploy(@array![]).unwrap();
        let last_owner = starknet::contract_address_const::<
            0x05c8Ec0993aFC0D6b928f0c41521bE62708BaCabd3E3bAA988b2DCaaB1aEd801
        >();

        // Create a dispatcher
        let dispatcher = IERC721MixinDispatcher { contract_address };

        let num_dojo_address = get_dojo_addresses().len() * 6;

        dispatcher.airdrop_dojo();
        let token_owner = dispatcher.owner_of(num_dojo_address.into());
        assert(token_owner == last_owner, 'Invalid token owner');
    }

    #[test]
    fn test_airdrop_counts() {
        let dojo_games_per_address = 6;
        let dojo_addresses = get_dojo_addresses();
        println!("dojo_addresses: {}", dojo_addresses.len());
        assert(dojo_addresses.len() == 43, 'wrong dojo count');
        let total_dojo_games = dojo_addresses.len() * dojo_games_per_address;

        let starkware_games_per_address = 6;
        let starkware_addresses = get_starkware_addresses();
        println!("starkware_addresses: {}", starkware_addresses.len());
        assert(starkware_addresses.len() == 39, 'wrong starkware count');
        let total_starkware_games = starkware_addresses.len() * starkware_games_per_address;

        let argent_games_per_address = 4;
        let argent_addresses = get_argent_addresses();
        println!("argent_addresses: {}", argent_addresses.len());
        assert(argent_addresses.len() == 23, 'wrong argent count');
        let total_argent_games = argent_addresses.len() * argent_games_per_address;

        let dope_wars_games_per_address = 5;
        let dope_wars_addresses = get_dope_wars_addresses();
        println!("dope_wars_addresses: {}", dope_wars_addresses.len());
        assert(dope_wars_addresses.len() == 13, 'wrong dope wars count');
        let total_dope_wars_games = dope_wars_addresses.len() * dope_wars_games_per_address;

        let _1337_games_per_address = 6;
        let _1337_addresses = get_1337_addresses();
        println!("1337_addresses: {}", _1337_addresses.len());
        assert(_1337_addresses.len() == 13, 'wrong 1337 count');
        let total_1337_games = _1337_addresses.len() * _1337_games_per_address;

        let stark_id_games_per_address = 1;
        let stark_id_addresses = get_stark_id_addresses();
        println!("stark_id_addresses: {}", stark_id_addresses.len());
        assert(stark_id_addresses.len() == 231, 'wrong stark id count');
        let total_stark_id_games = stark_id_addresses.len() * stark_id_games_per_address;

        let defi_spring_games_per_address = 5;
        let defi_spring_addresses = get_defi_spring_addresses();
        println!("defi_spring_addresses: {}", defi_spring_addresses.len());
        assert(defi_spring_addresses.len() == 51, 'wrong defi spring count');
        let total_defi_spring_games = defi_spring_addresses.len() * defi_spring_games_per_address;

        let golden_token_games_per_address = 2;
        let golden_token_addresses = get_golden_token_addresses();
        println!("golden_token_addresses: {}", golden_token_addresses.len());
        assert(golden_token_addresses.len() == 160, 'wrong golden token count');
        let total_golden_token_games = golden_token_addresses.len()
            * golden_token_games_per_address;

        let loot_games_per_address = 7;
        let loot_addresses = get_loot_addresses();
        println!("loot_addresses: {}", loot_addresses.len());
        assert(loot_addresses.len() == 9, 'wrong loot count');
        let total_loot_games = loot_addresses.len() * loot_games_per_address;

        let remainder_games = 4;

        let total_games = total_starkware_games
            + total_dojo_games
            + total_argent_games
            + total_dope_wars_games
            + total_1337_games
            + total_stark_id_games
            + total_defi_spring_games
            + total_golden_token_games
            + total_loot_games
            + remainder_games;

        println!("total_starkware_games: {}", total_starkware_games);
        println!("total_dojo_games: {}", total_dojo_games);
        println!("total_argent_games: {}", total_argent_games);
        println!("total_dope_wars_games: {}", total_dope_wars_games);
        println!("total_1337_games: {}", total_1337_games);
        println!("total_stark_id_games: {}", total_stark_id_games);
        println!("total_defi_spring_games: {}", total_defi_spring_games);
        println!("total_golden_token_games: {}", total_golden_token_games);
        println!("total_loot_games: {}", total_loot_games);
        println!("remainder_games: {}", remainder_games);
        println!("total_games: {}", total_games);
        assert(total_games == 1600, 'total games is wrong');
    }
}

#[starknet::interface]
trait ILootSurvivor<TContractState> {
    // @dev this is only function we need for this contract
    fn get_launch_tournament_winner(self: @TContractState) -> ContractAddress;
}
