import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';

final grpcServiceProvider =
    NotifierProvider<GrpcService, ClientChannel>(GrpcService.new);

class GrpcService extends Notifier<ClientChannel> {
  @override
  ClientChannel build() => ClientChannel(
        "localhost",
        port: 50051,
        options:
            const ChannelOptions(credentials: ChannelCredentials.insecure()),
      );

  ClientChannel get channel => state;

  void updateChannel(String host, int port) {
    state.shutdown(); // 기존 채널 종료
    // 새로운 채널로 상태 업데이트
    state = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
  }
}
