String translateFirebaseError(String code) {
  switch (code) {
    case 'invalid-email':
      return 'E-mail inválido.';
    case 'user-disabled':
      return 'Essa conta foi desativada.';
    case 'user-not-found':
      return 'Usuário não encontrado.';
    case 'wrong-password':
      return 'Senha incorreta.';
    case 'email-already-in-use':
      return 'Este e-mail já está em uso.';
    case 'operation-not-allowed':
      return 'Operação não permitida.';
    case 'weak-password':
      return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
    default:
      return 'Erro desconhecido. Tente novamente.';
  }
}
