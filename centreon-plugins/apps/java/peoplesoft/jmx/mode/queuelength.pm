#
# Copyright 2019 Centreon (http://www.centreon.com/)
#
# Centreon is a full-fledged industry-strength solution that meets
# the needs in IT infrastructure and application monitoring for
# service performance.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package apps::java::peoplesoft::jmx::mode::queuelength;

use base qw(centreon::plugins::mode);

use strict;
use warnings;

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(package => __PACKAGE__, %options);
    bless $self, $class;
    
    $options{options}->add_options(arguments =>
                                { 
                                  "warning:s"   => { name => 'warning' },
                                  "critical:s"  => { name => 'critical' },
                                });
    return $self;
}

sub check_options {
    my ($self, %options) = @_;
    $self->SUPER::init(%options);

    if (($self->{perfdata}->threshold_validate(label => 'warning', value => $self->{option_results}->{warning})) == 0) {
        $self->{output}->add_option_msg(short_msg => "Wrong warning threshold '" . $self->{option_results}->{warning} . "'.");
        $self->{output}->option_exit();
    }
    if (($self->{perfdata}->threshold_validate(label => 'critical', value => $self->{option_results}->{critical})) == 0) {
        $self->{output}->add_option_msg(short_msg => "Wrong critical threshold '" . $self->{option_results}->{critical} . "'.");
        $self->{output}->option_exit();
    }
}

sub run {
    my ($self, %options) = @_;
    $self->{connector} = $options{custom};

    my $mbean = "com.bea:Name=weblogic.kernel.Default,Server=PIA,Type=ExecuteQueue";
    $self->{request} = [
         { mbean => $mbean, attributes => [ { name => 'QueueLength' } ] },
    ];
    my $result = $self->{connector}->get_attributes(request => $self->{request}, nothing_quit => 1);
    
    my $exit = $self->{perfdata}->threshold_check(value => $result->{$mbean}->{QueueLength},
                                                  threshold => [ { label => 'critical', exit_litteral => 'critical' }, { label => 'warning', exit_litteral => 'warning' } ]);

    $self->{output}->perfdata_add(label => 'queue',
                                  value => $result->{$mbean}->{QueueLength},
                                  warning => $self->{perfdata}->get_perfdata_for_output(label => 'warning'),
                                  critical => $self->{perfdata}->get_perfdata_for_output(label => 'critical'),
                                  min => 0);

    $self->{output}->output_add(severity => $exit,
                                short_msg => sprintf("Queue Length : %s", $result->{$mbean}->{QueueLength}));
    $self->{output}->display();
    $self->{output}->exit();
}

1;

__END__

=head1 MODE

Check queue length.

=over 8

=item B<--warning>

Threshold warning

=item B<--critical>

Threshold critical

=back

=cut