### EXECUTE OS SEGUINTES COMANDOS

### BAIXAR ARQUIVOS DE INSTALAÇÃO

### PA E XRDP
wget https://raw.githubusercontent.com/sandross89/pa-xrdp/main/pa.sh

wget https://raw.githubusercontent.com/sandross89/pa-xrdp/main/xrdp.sh

### COLOCANDO PERMISSÃO DE EXECUÇÃO
chmod +x ./pa.sh

chmod +x ./xrdp.sh

### EXECUTAR ARQUIVO
./pa.sh

sudo ./xrdp.sh

### ATIVAR SESSÃO AVANÇADA HYPER-V
Set-VM -VMName NOME DA SUA VM -EnhancedSessionTransportType HvSocket
