use core::starknet::ContractAddress;

#[starknet::interface]
trait IGame<T> {
    fn mint(
        ref self: T, to: ContractAddress, beast: u8, prefix: u8, suffix: u8, level: u16, health: u16
    );
    fn isMinted(self: @T, beast: u8, prefix: u8, suffix: u8) -> bool;
    fn getMinter(self: @T) -> ContractAddress;
}

#[starknet::contract]
mod Syndicate {
    use super::IERC721Mixin;
    use core::starknet::{ContractAddress, contract_address_const, storage::{Map}};
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
        _isCollectionAirdropped: Map::<u8, bool>,
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

            // TODO: Get win from game contract
            return create_metadata(token_id.try_into().unwrap(), community_id, false);
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

        fn airdrop_dojo(ref self: ContractState) {
            _airdrop_dojo(ref self);
        }

        fn airdrop_starkware(ref self: ContractState) {
            _airdrop_starkware(ref self);
        }

        fn airdrop_argent(ref self: ContractState) {
            _airdrop_argent(ref self);
        }

        fn airdrop_dope_wars(ref self: ContractState) {
            _airdrop_dope_wars(ref self);
        }

        fn airdrop_1337(ref self: ContractState) {
            _airdrop_1337(ref self);
        }

        fn airdrop_stark_id(ref self: ContractState) {
            _airdrop_stark_id(ref self);
        }

        fn airdrop_defi_spring(ref self: ContractState) {
            _airdrop_defi_spring(ref self);
        }

        fn airdrop_golden_token(ref self: ContractState) {
            _airdrop_golden_token(ref self);
        }

        fn airdrop_loot(ref self: ContractState) {
            _airdrop_loot(ref self);
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

        // mint dojo syndicate addresses
        let mut addresses = get_dojo_addresses();
        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    self.erc721.mint(*address, token_count.into());
                    token_count += 1;
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

        // mint dojo syndicate addresses
        let mut addresses = get_starkware_addresses();
        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    self.erc721.mint(*address, token_count.into());
                    token_count += 1;
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

        // mint dojo syndicate addresses
        let mut addresses = get_argent_addresses();
        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    self.erc721.mint(*address, token_count.into());
                    token_count += 1;
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

        // mint dojo syndicate addresses
        let mut addresses = get_dope_wars_addresses();
        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    self.erc721.mint(*address, token_count.into());
                    token_count += 1;
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

        // mint dojo syndicate addresses
        let mut addresses = get_1337_addresses();
        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    self.erc721.mint(*address, token_count.into());
                    token_count += 1;
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

        // mint dojo syndicate addresses
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

        // mint dojo syndicate addresses
        let mut addresses = get_defi_spring_addresses();
        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    self.erc721.mint(*address, token_count.into());
                    token_count += 1;
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

        // mint dojo syndicate addresses
        let mut addresses = get_golden_token_addresses();
        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    self.erc721.mint(*address, token_count.into());
                    token_count += 1;
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

        // mint dojo syndicate addresses
        let mut addresses = get_loot_addresses();
        loop {
            match addresses.pop_front() {
                Option::Some(address) => {
                    self.erc721.mint(*address, token_count.into());
                    token_count += 1;
                },
                Option::None(_) => { break; }
            };
        };

        self._collectionTokenEndIndex.write(9, token_count);
        self._isCollectionAirdropped.write(9, true);

        token_count
    }

    #[inline(always)]
    pub fn get_dojo_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_starkware_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_argent_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_dope_wars_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_1337_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_stark_id_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_defi_spring_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_golden_token_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
        ]
            .span()
    }

    #[inline(always)]
    pub fn get_loot_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
            >(),
            contract_address_const::<
                0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
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

    fn airdrop_dojo(ref self: TState);
    fn airdrop_starkware(ref self: TState);
    fn airdrop_argent(ref self: TState);
    fn airdrop_dope_wars(ref self: TState);
    fn airdrop_1337(ref self: TState);
    fn airdrop_stark_id(ref self: TState);
    fn airdrop_defi_spring(ref self: TState);
    fn airdrop_golden_token(ref self: TState);
    fn airdrop_loot(ref self: TState);
}

#[cfg(test)]
mod tests {
    use core::num::traits::Zero;
    use snforge_std::{
        declare, ContractClassTrait, start_cheat_caller_address_global,
        stop_cheat_caller_address_global
    };
    use super::{IERC721MixinDispatcher, IERC721MixinDispatcherTrait, Syndicate::get_dojo_addresses};

    // #[test]
    // fn test_balance_counts() {
    //     let contract = declare("Syndicate").unwrap();
    //     let (contract_address, _) = contract.deploy(@array![]).unwrap();
    //     // Create a dispatcher
    //     let dispatcher = IERC721MixinDispatcher { contract_address };

    //     let dojo_addresses = dispatcher.get_dojo_addresses();

    //     println!("dojo addresses: {}", dojo_addresses);
    // }

    #[test]
    fn test_erc721_basic_functionality() {
        let contract = declare("Syndicate").unwrap();
        let (contract_address, _) = contract.deploy(@array![]).unwrap();

        // Test address
        let owner = starknet::contract_address_const::<
            0x07bc3639e3e1aa3251a19c60402300085fcb5a9ea1c09ac6aa7dc45aef68e1c1
        >();

        // Create a dispatcher
        let dispatcher = IERC721MixinDispatcher { contract_address };

        dispatcher.airdrop_dojo();
        let owner_balance = dispatcher.balance_of(owner);
        assert(owner_balance == 43, 'Invalid dojo airdrop');

        dispatcher.airdrop_starkware();
        let owner_balance = dispatcher.balance_of(owner);
        assert(owner_balance == 82, 'Invalid starkware airdrop');

        dispatcher.airdrop_argent();
        let owner_balance = dispatcher.balance_of(owner);
        assert(owner_balance == 105, 'Invalid argent airdrop');

        dispatcher.airdrop_dope_wars();
        let owner_balance = dispatcher.balance_of(owner);
        assert(owner_balance == 118, 'Invalid dope wars airdrop');

        dispatcher.airdrop_1337();
        let owner_balance = dispatcher.balance_of(owner);
        assert(owner_balance == 131, 'Invalid 1337 airdrop');

        dispatcher.airdrop_stark_id();
        let owner_balance = dispatcher.balance_of(owner);
        assert(owner_balance == 296, 'Invalid stark id airdrop');

        dispatcher.airdrop_defi_spring();
        let owner_balance = dispatcher.balance_of(owner);
        assert(owner_balance == 347, 'Invalid defi spring airdrop');

        dispatcher.airdrop_golden_token();
        let owner_balance = dispatcher.balance_of(owner);
        assert(owner_balance == 507, 'Invalid golden token airdrop');

        dispatcher.airdrop_loot();
        let owner_balance = dispatcher.balance_of(owner);
        assert(owner_balance == 516, 'Invalid loot airdrop');

        let token_owner = dispatcher.owner_of(1);
        assert(token_owner == owner, 'Invalid token owner');

        // Transfer the token
        start_cheat_caller_address_global(owner);
        let recipient = starknet::contract_address_const::<0x2>();
        dispatcher.transfer_from(owner, recipient, 1);
        stop_cheat_caller_address_global();

        // Check updated balances and ownership
        let new_owner_balance = dispatcher.balance_of(owner);
        assert(new_owner_balance == 515, 'Invalid new owner balance');

        let recipient_balance = dispatcher.balance_of(recipient);
        assert(recipient_balance == 1, 'Invalid recipient balance');

        let new_token_owner = dispatcher.owner_of(1);
        assert(new_token_owner == recipient, 'Invalid new token owner');

        // Check name and symbol
        let name = dispatcher.name();
        assert(name == "The Syndicate", 'Invalid name');

        let symbol = dispatcher.symbol();
        assert(symbol == "SYN", 'Invalid symbol');
    }
}
