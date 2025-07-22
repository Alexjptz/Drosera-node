# Drosera-node
Drosera installation script and guide (HOODI TESTNET)

## Prerequisites
Ubuntu/Linux environment (WSL Ubuntu works well)
At least 4 CPU cores and 8GB RAM recommended
Basic CLI knowledge
Ethereum private key with funds on Hoodi testnet
Open ports: 31313 and 31314 (or your configured ports)


## Faucet Links
To mine or interact with contracts on the Hoodi Testnet, you'll need test ETH:

### Mining Faucet:
https://hoodi-faucet.pk910.de

### Public Faucets:
[QUICKNODE](https://faucet.quicknode.com/ethereum/hoodi)
[STAKELY](https://stakely.io/faucet/ethereum-hoodi-testnet-eth)

## Download script
<pre> <code>bash <(curl -s https://raw.githubusercontent.com/Alexjptz/Drosera-node/master/drosera_hoodi_node.sh)</code> </pre>

## Получение роли Cadet в Discord (Hoodi Edition)

Если ваша ловушка (`Trap`) уже развёрнута и оператор работает, вы можете отправить своё Discord-имя в сеть, чтобы получить эксклюзивную роль **Cadet**.

### 1. Создайте новый Trap-контракт
<pre><code>cd ~/my-drosera-trap
nano src/Trap.sol</code></pre>

Вставьте следующее содержимое:
<pre><code>// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IMockResponse {
    function isActive() external view returns (bool);
}

contract Trap is ITrap {
    address public constant RESPONSE_CONTRACT = 0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608;
    string constant discordName = "YOURDISCORD"; // замените на ваш Discord username

    function collect() external view returns (bytes memory) {
        bool active = IMockResponse(RESPONSE_CONTRACT).isActive();
        return abi.encode(active, discordName);
    }

    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        (bool active, string memory name) = abi.decode(data[0], (bool, string));
        if (!active || bytes(name).length == 0) {
            return (false, bytes(""));
        }

        return (true, abi.encode(name));
    }
}</code></pre>
💡 Нажмите Ctrl + X, затем Y, и Enter для сохранения.

### 2. Обновите конфигурацию drosera.toml
<pre><code>ethereum_rpc = "https://ethereum-hoodi-rpc.publicnode.com"
drosera_rpc = "https://relay.hoodi.drosera.io"
eth_chain_id = 560048
drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

[traps]

[traps.mytrap]
path = "out/Trap.sol/Trap.json"
response_contract = "0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608"
response_function = "respondWithDiscordName(string)"
cooldown_period_blocks = 33
min_number_of_operators = 1
max_number_of_operators = 2
block_sample_size = 10
private_trap = true
whitelist = ["YOUR_OPERATOR_ADDRESS"]
address = "YOUR_TRAP_CONFIG_ADDRESS"</code> </pre>

### 3. Деплой ловушки
Скомпилируйте контракт:
<pre><code>forge build</code></pre>

Если команда недоступна:
<pre><code>source /root/.bashrc</code></pre>

Проверьте ловушку перед применением:
<pre><code>drosera dryrun</code></pre>

Примените и задеплойте:
<pre><code>drosera apply --private-key XXX</code></pre>
🛡️ Замените xxx на приватный ключ EVM-кошелька **(должен быть с балансом в Hoodi ETH).**

### 4. Проверка отклика ловушки
<pre><code>source /root/.bashrc</code></pre>
<pre><code>cast call 0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608 \
  "isResponder(address)(bool)" OWNER_ADDRESS \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com</code></pre>
Замените OWNER_ADDRESS на адрес своего кошелька **(не адрес ловушки!)**.

**Деплой может занять несколько минут!!!**
Если результат **true** — всё работает 🎉

### 5. Перезапустите оператора
<pre><code>cd ~/Drosera-Network
docker compose up -d</code></pre>

### 6. Посмотреть отправленные Discord-имена
<pre><code>source /root/.bashrc</code></pre>
<pre><code>cast call 0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608 \
  "getDiscordNamesBatch(uint256,uint256)(string[])" 0 2000 \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com</code></pre>

Найдите там свое discord имя и ожидайте получение роли **(автоматически)**

